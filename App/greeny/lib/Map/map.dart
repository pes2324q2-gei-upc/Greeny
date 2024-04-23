import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/Map/utils/locations.dart';
import 'package:greeny/app_state.dart';
import 'package:provider/provider.dart';
import 'utils/locations.dart' as locations;
// ignore: library_prefixes
import 'utils/markers_helper.dart' as markersHelper;
import 'package:fluster/fluster.dart';
import 'utils/map_marker.dart';
import 'utils/map_helper.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool serviceEnabled = false;
  LocationPermission permission = LocationPermission.denied;
  Map<String, bool> get transports =>
      Provider.of<AppState>(context, listen: false).transports;
  Color disabledColor = const Color.fromARGB(97, 0, 0, 0);
  // ignore: prefer_typing_uninitialized_variables
  Map icons = {};
  // ignore: prefer_typing_uninitialized_variables
  Locations stations = locations.Locations(
      stations: locations.Stations(
          publicTransportStations: [],
          busStations: [],
          bicingStations: [],
          chargingStations: []));

  //nous
  Set<Marker> get _markerss =>
      Provider.of<AppState>(context, listen: false).markers;
  final int _minClusterZoom = 0;
  final int _maxClusterZoom = 19;
  Fluster<MapMarker>? _clusterManager;

  MapType _currentMapType = MapType.normal;
  final mapTypeList = ["Normal", "Hybrid", "Satellite", "Terrain"];
  bool isLoading = true;
  bool gettingLocation = true;
  GoogleMapController? mapController;
  final Map<int, int> _zoomToDistance = {
    0: 4294967296,
    1: 4294967296,
    2: 4294967296,
    3: 4294967296,
    4: 4294967296,
    5: 4294967296,
    6: 4294967296,
    7: 15000,
    8: 15000,
    9: 10000,
    10: 4000,
    11: 3000,
    12: 2000,
    13: 1000,
    14: 500,
    15: 300,
    16: 200,
    17: 100,
    18: 0,
    19: 0,
    20: 0,
    21: 0,
    22: 0
  };
  // ignore: prefer_typing_uninitialized_variables
  var t;
  CameraPosition camposition =
      const CameraPosition(target: LatLng(0, 0), zoom: 16);

  Future<void> _updateMarkers(
      CameraPosition newposition, bool moving, bool forceupdate) async {
    if (!forceupdate &&
        _markerss.isNotEmpty &&
        camposition.target.latitude == newposition.target.latitude) {
      return;
    }

    var dist = markersHelper.distanceBetweenTwoCoords(
        newposition.target, camposition.target);

    if (moving &&
        dist < _zoomToDistance[newposition.zoom.toInt()]! &&
        camposition.zoom.toInt() == newposition.zoom.toInt()) {
      return;
    }

    var visible = await mapController!.getVisibleRegion();

    final List<MapMarker> markers = markersHelper.getMarkers(
        // ignore: use_build_context_synchronously
        transports,
        icons,
        stations,
        visible,
        newposition.target,
        // ignore: use_build_context_synchronously
        context);

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );

    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager,
      newposition.zoom,
      // ignore: use_build_context_synchronously
      Theme.of(context).colorScheme.primary,
      Colors.white,
      // ignore: use_build_context_synchronously
      (MediaQuery.of(context).devicePixelRatio.toInt() * 20),
    );

    camposition = newposition;

    setState(() {
      _markerss
        ..clear()
        ..addAll(updatedMarkers);
    });
  }

  @override
  void initState() {
    t = Timer(const Duration(seconds: 5), () {
      showMessage('This is taking more than expected.');
    });
    camposition = Provider.of<AppState>(context, listen: false).cameraPosition;
    getLocation();
    getInfo();
    _gotoLocation();
    super.initState();
  }

  Future<void> getInfo() async {
    stations = Provider.of<AppState>(context, listen: false).stations;
    if (stations.stations.publicTransportStations.isEmpty) {
      stations = await locations.getStations();
      // ignore: use_build_context_synchronously
      Provider.of<AppState>(context, listen: false).setStations(stations);
    }
    // ignore: use_build_context_synchronously
    icons = Provider.of<AppState>(context, listen: false).icons;
    if (icons['BUS'] == null) {
      icons = await markersHelper
          // ignore: use_build_context_synchronously
          .createIcons(MediaQuery.of(context).devicePixelRatio.toInt() * 20);
      // ignore: use_build_context_synchronously
      Provider.of<AppState>(context, listen: false).setIcons(icons);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getLocation() async {
    if (camposition.target.latitude != 0 || camposition.target.longitude != 0) {
      if (mounted) {
        setState(() {
          gettingLocation = false;
        });
      }
    }
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showAlert('Location services are disabled.');
      t.cancel();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showAlert(
            'Location permissions are denied, we cannot request permissions.');
        t.cancel();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showAlert(
          'Location permissions are permanently denied, we cannot request permissions.');
      t.cancel();
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        gettingLocation = false;
        camposition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 16);
        Provider.of<AppState>(context, listen: false)
            .setCameraPosition(camposition);
      });
    }
  }

  late AppState appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appState = Provider.of<AppState>(context, listen: false);
  }

  @override
  void dispose() {
    // Use the saved reference to AppState here
    appState.setCameraPosition(camposition);
    appState.setStations(stations);

    // Don't forget to dispose your other resources such as controllers
    mapController?.dispose();

    super.dispose();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    t.cancel();
    mapController = controller;
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || gettingLocation) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 220, 255, 255),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Consumer<AppState>(
        builder: (context, appState, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(translate('Filter'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final transport in transports.keys)
                          IconButton(
                            onPressed: () => filter(transport),
                            icon: Image(
                              image: AssetImage(
                                  'assets/transports/$transport.png'),
                              height: MediaQuery.of(context)
                                      .devicePixelRatio
                                      .toInt() *
                                  12,
                              width: MediaQuery.of(context)
                                      .devicePixelRatio
                                      .toInt() *
                                  12,
                              color:
                                  transports[transport]! ? null : disabledColor,
                              colorBlendMode: BlendMode.dstIn,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                GoogleMap(
                    myLocationEnabled: true,
                    mapType: _currentMapType,
                    myLocationButtonEnabled: true,
                    mapToolbarEnabled: true,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: camposition,
                    markers: Set<Marker>.of(appState.markers),
                    onCameraMove: (position) => {
                          _updateMarkers(position, true, false),
                        }),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FloatingActionButton(
                      onPressed: _mapType,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.map),
                    ),
                  )
                ]),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _gotoLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(camposition));
  }

  Future<void> filter(String type) async {
    setState(() {
      transports[type] = !transports[type]!;
    });
    _updateMarkers(camposition, false, true);
  }

  void _mapType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Map type')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                for (final type in mapTypeList)
                  ListTile(
                    title: Text(translate(type)),
                    onTap: () {
                      _changeMapType(type);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeMapType(String type) {
    setState(() {
      switch (type) {
        case "Normal":
          _currentMapType = MapType.normal;
          break;
        case "Hybrid":
          _currentMapType = MapType.hybrid;
          break;
        case "Satellite":
          _currentMapType = MapType.satellite;
          break;
        case "Terrain":
          _currentMapType = MapType.terrain;
          break;
      }
    });
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(translate(message)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(translate('Close')),
            ),
          ],
        );
      },
    );
  }

  void showMessage(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate(m)),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/Map/utils/locations.dart';
import 'package:greeny/utils/app_state.dart';
import 'package:provider/provider.dart';
import 'utils/locations.dart' as locations;
// ignore: library_prefixes
import 'utils/markers_helper.dart' as markersHelper;
import 'package:fluster/fluster.dart';
import 'utils/map_marker.dart';
import 'utils/map_helper.dart';
import 'package:greeny/utils/utils.dart';
import 'package:greeny/City/location_service.dart';

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
  bool get fav => Provider.of<AppState>(context, listen: false).fav;
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
  bool gettingLocation = true;
  GoogleMapController? mapController;
  // ignore: prefer_typing_uninitialized_variables
  var t;
  CameraPosition camposition =
      const CameraPosition(target: LatLng(0, 0), zoom: 16);
  Set<String> favStations = {};
  Timer? _debounce;

  Future<void> _updateMarkers(CameraPosition newposition) async {
    var visible = await mapController!.getVisibleRegion();

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      stations = await locations.getStations(visible);
      // rest of your code
    });

    final List<MapMarker> markers = await markersHelper.getMarkers(
        // ignore: use_build_context_synchronously
        transports,
        icons,
        stations,
        visible,
        fav,
        newposition.target,
        // ignore: use_build_context_synchronously
        context,
        favStations);

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
      if (mounted) {
        showMessage(context, translate('This is taking more than expected.'));
      }
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
      var visible = LatLngBounds(
          northeast: const LatLng(0, 0), southwest: const LatLng(0, 0));
      stations = await locations.getStations(visible);
      favStations = await markersHelper.getFavoriteStations();
      if (mounted) {
        Provider.of<AppState>(context, listen: false).setStations(stations);
      }
    }
    if (mounted) {
      icons = Provider.of<AppState>(context, listen: false).icons;
    }
    if (icons['BUS'] == null) {
      if (mounted) {
        icons = await markersHelper
            .createIcons(MediaQuery.of(context).devicePixelRatio.toInt() * 20);
      }
      if (mounted) {
        Provider.of<AppState>(context, listen: false).setIcons(icons);
      }
    }
  }

  Future<void> getLocation() async {
    if (camposition.target.latitude != 0 || camposition.target.longitude != 0) {
      if (mounted) {
        setState(() {
          gettingLocation = false;
        });
        return;
      }
    }
    bool islocationEnabled = await LocationService.instance.comprovarUbicacio();
    if (!islocationEnabled) {
      // ignore: use_build_context_synchronously
      showAlert('Location services are disabled');
      t.cancel();
      return;
    }

    var position =
        // ignore: use_build_context_synchronously
        Provider.of<AppState>(context, listen: false).previousPosition;

    if (position == null) {
      // ignore: use_build_context_synchronously
      await LocationService.instance.startLocationUpdates(context);

      // ignore: use_build_context_synchronously
      AppState appState = Provider.of<AppState>(context, listen: false);

      while (appState.previousPosition == null) {
        await Future.delayed(const Duration(
            seconds: 1)); // wait for a second before trying again
      }

      position = appState.previousPosition;
      // ignore: use_build_context_synchronously
      locationService?.stopLocationUpdates(context);
    }

    if (mounted) {
      setState(() {
        gettingLocation = false;
        camposition = CameraPosition(
            target: LatLng(position!.latitude, position.longitude), zoom: 16);
        Provider.of<AppState>(context, listen: false)
            .setCameraPosition(camposition);
      });
    }
  }

  late AppState appState;
  LocationService? locationService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appState = Provider.of<AppState>(context, listen: false);
    locationService = LocationService.instance;
  }

  @override
  void dispose() {
    // Use the saved reference to AppState here
    appState.setCameraPosition(camposition);
    appState.setStations(stations);
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
    if (gettingLocation) {
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
              title: Text(translate('Map'),
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
                          _updateMarkers(position),
                        }),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FloatingActionButton(
                          onPressed: _mapType,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.map),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FloatingActionButton(
                          onPressed: _showHideFav,
                          backgroundColor: Colors.white,
                          child: fav
                              ? const Icon(Icons.favorite, color: Colors.pink)
                              : const Icon(Icons.favorite_border,
                                  color: Colors.pink),
                        ),
                      ),
                    ],
                  ),
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
    _updateMarkers(camposition);
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

  void _showHideFav() async {
    favStations = await markersHelper.getFavoriteStations();
    // ignore: use_build_context_synchronously
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      appState.setFav(!appState.fav);
    });
    _updateMarkers(camposition);
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
}

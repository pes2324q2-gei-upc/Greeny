import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'utils/locations.dart' as locations;
import 'station.dart';
import 'utils/markers.dart' as markers;
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
  LatLng _center = const LatLng(0.0, 0.0);
  bool serviceEnabled = false;
  LocationPermission permission = LocationPermission.denied;
  double iconSize = 35;
  var transports = {
    'tram': true,
    'bus': true,
    'fgc': true,
    'bicing': true,
    'renfe': true,
    'car': true,
    'metro': true
  };
  Color disabledColor = const Color.fromARGB(97, 0, 0, 0);
  // ignore: prefer_typing_uninitialized_variables
  var icons;
  // ignore: prefer_typing_uninitialized_variables
  var stations;

  //nous
  final Set<Marker> _markerss = {};
  final int _minClusterZoom = 0;
  final int _maxClusterZoom = 19;
  Fluster<MapMarker>? _clusterManager;
  double _currentZoom = 15;
  // ignore: unused_field
  bool _areMarkersLoading = true;
  MapType _currentMapType = MapType.normal;
  final mapTypeList = ["Normal", "Hybrid", "Satellite", "Terrain"];

  void _initMarkers() async {
    final List<MapMarker> markers = [];

    for (final station in stations.stations) {
      markers.add(
        MapMarker(
          id: station.name,
          position: LatLng(station.latitude, station.longitude),
          icon: BitmapDescriptor.fromBytes(
              icons[station.stops[0].transportType.type]),
          onTap: () => _gotoStation(station),
        ),
      );
    }

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );

    await _updateMarkers();
  }

  Future<void> _updateMarkers([double? updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager,
      _currentZoom,
      Theme.of(context).colorScheme.primary,
      Colors.white,
      60,
    );

    _markerss
      ..clear()
      ..addAll(updatedMarkers);

    setState(() {
      _areMarkersLoading = false;
    });
  }

  @override
  void initState() {
    getLocation();
    getInfo();
    _gotoLocation();
    super.initState();
  }

  Future<void> getInfo() async {
    stations = await locations.getStations();
    icons = await markers.createIcons(60);
  }

  Future<void> getLocation() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
            'Location permissions are denied, we cannot request permissions.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _initMarkers();
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    if (!serviceEnabled) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Filter'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final transport in transports.keys)
                    IconButton(
                      onPressed: () => filter(transport),
                      icon: Image(
                        image: AssetImage('assets/transports/$transport.png'),
                        height: iconSize,
                        width: iconSize,
                        color: transports[transport]! ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      ),
                    ),
                ],
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
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _currentZoom,
              ),
              markers: _markerss,
              onCameraMove: (position) => _updateMarkers(position.zoom),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: _mapType,
                  child: const Icon(Icons.map),
                ),
              )
            ]),
          ],
        ),
      );
    }
  }

  Future<void> _gotoLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: _center,
      zoom: 14.4746,
    )));
  }

  Future<void> filter(String type) async {
    setState(() {
      transports[type] = !transports[type]!;
    });
  }

  void _gotoStation(locations.Station station) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StationPage(station: station)),
    );
  }

  void _mapType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Map type'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                for (final type in mapTypeList)
                  ListTile(
                    title: Text(type),
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
}

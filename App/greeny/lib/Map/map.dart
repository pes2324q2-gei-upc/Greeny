import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'utils/locations.dart' as locations;
import 'station.dart';
import 'utils/markers.dart' as markers;

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

  @override
  void initState() {
    getLocation();
    _gotoLocation();
    super.initState();
  }

  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final icons = await markers.createIcons(50);
    final stations = await locations.getStations();
    setState(() {
      _markers.clear();
      for (final station in stations.stations) {
        for (final stops in station.stops) {
          final marker = Marker(
              markerId: MarkerId(station.name),
              position: LatLng(station.latitude, station.longitude),
              icon: BitmapDescriptor.fromBytes(icons[stops.transportType.type]),
              onTap: () => _gotoStation(station));
          _markers[station.name] = marker;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (serviceEnabled == false) {
      return const Scaffold(
        body: Center(
          child: Text('Loading...'),
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
        body: GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.4746,
          ),
          markers: _markers.values.toSet(),
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
}

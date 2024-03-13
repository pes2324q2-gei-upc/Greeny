import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  bool enabledTram = true;
  bool enabledBus = true;
  bool enabledFgc = true;
  bool enabledBicing = true;
  bool enabledRenfe = true;
  bool enabledCar = true;
  bool enabledMetro = true;
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
                  IconButton(
                      onPressed: () => filter('tram'),
                      icon: Image(
                        image: const AssetImage('assets/transports/tram.png'),
                        height: iconSize,
                        width: iconSize,
                        color: enabledTram ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      )),
                  IconButton(
                      onPressed: () => filter('metro'),
                      icon: Image(
                        image: const AssetImage('assets/transports/metro.png'),
                        height: iconSize,
                        width: iconSize,
                        color: enabledMetro ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      )),
                  IconButton(
                      onPressed: () => filter('bus'),
                      icon: Image(
                        image: const AssetImage('assets/transports/bus.png'),
                        height: iconSize,
                        width: iconSize,
                        color: enabledBus ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      )),
                  IconButton(
                      onPressed: () => filter('fgc'),
                      icon: Image(
                        image: const AssetImage('assets/transports/fgc.png'),
                        height: iconSize,
                        width: iconSize,
                        color: enabledFgc ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      )),
                  IconButton(
                      onPressed: () => filter('bicing'),
                      icon: Image(
                        image: const AssetImage('assets/transports/bicing.png'),
                        height: iconSize,
                        width: iconSize,
                        color: enabledBicing ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      )),
                  IconButton(
                      onPressed: () => filter('renfe'),
                      icon: Image(
                        image: const AssetImage('assets/transports/renfe.png'),
                        height: iconSize,
                        width: iconSize,
                        color: enabledRenfe ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      )),
                  IconButton(
                      onPressed: () => filter('car'),
                      icon: Image(
                        image: const AssetImage('assets/transports/car.png'),
                        height: iconSize,
                        width: iconSize,
                        color: enabledCar ? null : disabledColor,
                        colorBlendMode: BlendMode.dstIn,
                      )),
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
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.4746,
          ),
          onTap: (position) {
            print(position);
          },
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

  void filter(String type) {
    if (type == 'tram') {
      setState(() {
        enabledTram = !enabledTram;
      });
    } else if (type == 'bus') {
      setState(() {
        enabledBus = !enabledBus;
      });
    } else if (type == 'fgc') {
      setState(() {
        enabledFgc = !enabledFgc;
      });
    } else if (type == 'bicing') {
      setState(() {
        enabledBicing = !enabledBicing;
      });
    } else if (type == 'renfe') {
      setState(() {
        enabledRenfe = !enabledRenfe;
      });
    } else if (type == 'car') {
      setState(() {
        enabledCar = !enabledCar;
      });
    } else if (type == 'metro') {
      setState(() {
        enabledMetro = !enabledMetro;
      });
    }
  }
}

import 'package:geolocator/geolocator.dart';

double km = 0;

Future<void> comptakm() async {
  comprovarUbicacio();
  //await getLocation();
  startLocationUpdates();
}

Future<void> startLocationUpdates() async {
  Position? previousPosition;

  // ignore: unused_local_variable
  final stream = Geolocator.getPositionStream(
    desiredAccuracy: LocationAccuracy.high,
  ).listen((Position position) {
    if (previousPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        previousPosition!.latitude,
        previousPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Convertir la distancia de metros a kilómetros y actualizar el contador.
      double distanceInKm = distanceInMeters / 1000;
      km += distanceInKm;
    }

    previousPosition = position;
  });
}

/* Future<void> getLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  } catch (e) {
    print('Error obtaining location: $e');
  }
} */

Future<bool> comprovarUbicacio() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await Geolocator.openLocationSettings();
    if (!serviceEnabled) {
      print('Servei ubicació no habilitat');
      return false;
    }
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      print('Permis denegat');
      return false;
    }
  }

  print('Servei habilitat i permis otorgat');
  return true;
}

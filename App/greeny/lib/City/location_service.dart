import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/app_state.dart';
import 'package:provider/provider.dart';

//singleton per trackejar els km recorreguts
class LocationService {
  //instancia de la clase
  static LocationService? _instance;

  //constructora
  LocationService._();

  //stream dúbicacions que trackejara els km recorreguts
  late StreamSubscription<Position>? positionStream;

  //obtenir instancia de la clase
  static LocationService get instance {
    _instance ??= LocationService._(); // Crea la instancia si aún no existe
    return _instance!;
  }

  // crea un stream d'ubicacions i cada cop que canvia l'ubicació actualitza el comptador de km
  Future<void> startLocationUpdates(BuildContext context) async {
    AppState appState = context.read<AppState>(); // estat de l'aplicació
    // ignore: unused_local_variable
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter:
          10, // filtre per els metres que han de pasar per actualitzar els km
    ).listen((Position position) {
      if (appState.previousPosition != null) {
        double distanceInMeters = Geolocator.distanceBetween(
          appState.previousPosition!.latitude,
          appState.previousPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // Convertir la distancia de metros a kilómetros y actualizar el contador.
        double distanceInKm = distanceInMeters / 1000;
        appState.totalDistance += distanceInKm;
        //print(appState.totalDistance); //chivato per comprovar els km
      }
      appState.previousPosition = position;
    });
  }

  void stopLocationUpdates(BuildContext context) {
    positionStream?.cancel();
    context.read<AppState>().previousPosition = null;
  }
}

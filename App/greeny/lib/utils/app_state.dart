import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greeny/Map/utils/locations.dart';
import 'package:provider/provider.dart';

class AppState with ChangeNotifier {
  bool _isPlaying = false;
  double _totalDistance = 0.0;
  DateTime? _startedAt;
  // ignore: avoid_init_to_null
  late Position? _previousPosition =
      null; // posicio anterior per calcular els km desplaçats
  Set<Marker> markers = {};
  Map<String, bool> transports = {
    'tram': false,
    'bus': false,
    'fgc': false,
    'bicing': false,
    'renfe': false,
    'car': false,
    'metro': false
  };
  bool fav = false;
  CameraPosition cameraPosition =
      const CameraPosition(target: LatLng(0, 0), zoom: 16);

  bool get isPlaying => _isPlaying;
  double get totalDistance => _totalDistance;
  DateTime? get startedAt => _startedAt;
  Position? get previousPosition => _previousPosition;

  Locations stations = Locations(
      stations: Stations(
          publicTransportStations: [],
          busStations: [],
          bicingStations: [],
          chargingStations: []));

  Map icons = {
    'BUS': null,
    'BICING': null,
    'CAR': null,
    'FGC': null,
    'METRO': null,
    'RENFE': null,
    'TRAM': null
  };

  void setIcons(Map newIcons) {
    icons = newIcons;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setStations(Locations newStations) {
    stations = newStations;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setCameraPosition(CameraPosition newCameraPosition) {
    cameraPosition = newCameraPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setTransports(Map<String, bool> newTransports) {
    transports = newTransports;
    notifyListeners();
  }

  void setFav(bool newFav) {
    fav = newFav;
    notifyListeners();
  }

  set isPlaying(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPlaying = value;
      notifyListeners();
    });
  }

  set totalDistance(double value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _totalDistance = value;
      notifyListeners();
    });
  }

  set previousPosition(Position? newPosition) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousPosition = newPosition;
      notifyListeners();
    });
  }

  set startedAt(DateTime? value) {
    _startedAt = value;
    notifyListeners();
  }
}

final appStateProvider =
    ChangeNotifierProvider<AppState>(create: (context) => AppState());

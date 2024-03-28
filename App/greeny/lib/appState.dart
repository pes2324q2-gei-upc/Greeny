import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class AppState with ChangeNotifier {
  bool _isPlaying = false;
  double _totalDistance = 0.0;
  late Position? _previousPosition =
      null; // posicio anterior per calcular els km desplaçats

  bool get isPlaying => _isPlaying;
  double get totalDistance => _totalDistance;
  Position? get previousPosition => _previousPosition;

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  set totalDistance(double value) {
    _totalDistance = value;
    notifyListeners();
  }

  set previousPosition(Position? newPosition) {
    _previousPosition = newPosition;
    notifyListeners();
  }
}

final appStateProvider =
    ChangeNotifierProvider<AppState>(create: (context) => AppState());

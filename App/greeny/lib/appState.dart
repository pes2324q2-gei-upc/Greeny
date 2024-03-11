import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppState with ChangeNotifier {
  bool _isPlaying = false;
  double _totalDistance = 0.0;

  bool get isPlaying => _isPlaying;
  double get totalDistance => _totalDistance;

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  set totalDistance(double value) {
    _totalDistance = value;
    notifyListeners();
  }
}

final appStateProvider =
    ChangeNotifierProvider<AppState>(create: (context) => AppState());

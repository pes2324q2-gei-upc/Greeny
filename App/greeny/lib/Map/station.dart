import 'package:flutter/material.dart';
import 'package:greeny/Map/utils/locations.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key, required this.station});

  final Station station;

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {

  Station get station => widget.station;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
      ),
      body: Center(
        child: Text(station.stops.map((stop) => stop.transportType.type).join(', ')
      ),
      )
    );
  }
}

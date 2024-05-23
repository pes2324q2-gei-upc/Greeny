import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greeny/API/requests.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ExploreCity extends StatefulWidget {
  final String name;
  final String path;

  const ExploreCity({Key? key, required this.name, required this.path})
      : super(key: key);

  @override
  _ExploreCityState createState() => _ExploreCityState();
}

class _ExploreCityState extends State<ExploreCity> {
  late String icqa;

  @override
  void initState() {
    super.initState();
    fetchAirQualityIndex().then((value) {
      setState(() {
        icqa = value;
      });
    });
  }

  Future<String> fetchAirQualityIndex() async {
    try {
      var response = await httpPost('/api/get-icqa/',
          jsonEncode({"name": widget.name}), "application/json");
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        String data = res["icqa"].toString();
        return data;
      } else {
        throw Exception(
            'Failed to fetch ICQA. Status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Row(
          children: [
            Text(widget.name),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          width: 600,
          height: 600,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.air,
                        color: getAirQualityColor(icqa), size: 36.0),
                    const SizedBox(width: 8),
                    Text(icqa, style: const TextStyle(fontSize: 24.0)),
                  ],
                ),
              ),
              Expanded(
                child: ModelViewer(
                  debugLogging: true,
                  key: Key(widget.name),
                  src: 'assets/neighborhoods/${widget.path}',
                  autoRotate: true,
                  disableZoom: true,
                  disableTap: true,
                  rotationPerSecond: "25deg",
                  autoRotateDelay: 1000,
                  cameraControls: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color getAirQualityColor(String icqa) {
  switch (icqa) {
    case 'Bona':
      return Colors.cyan;
    case 'Raonablement bona':
      return Colors.green;
    case 'Regular':
      return Colors.yellow;
    case 'Desfavorable':
      return Colors.red;
    case 'Molt desfavorable':
      return const Color.fromARGB(255, 76, 1, 1);
    case 'Extremadament desfavorable':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

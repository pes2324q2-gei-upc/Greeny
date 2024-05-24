import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class GradientBar extends StatelessWidget {
  final String icqa;

  const GradientBar({super.key, required this.icqa});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 10), // Define el tamaño de tu barra aquí
      painter: GradientBarPainter(icqaToPercentage(icqa)),
    );
  }
}

class GradientBarPainter extends CustomPainter {
  final double percentage;

  GradientBarPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: const [
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.red,
        Color.fromARGB(255, 76, 1, 1),
        Colors.purple
      ],
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final radius = Radius.circular(size.height / 2);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    canvas.drawRRect(rrect, paint);

    final markerPaint = Paint()..color = Colors.white;

    canvas.drawCircle(
        Offset(size.width * percentage, size.height / 2), 5, markerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ExploreCity extends StatefulWidget {
  final String name;
  final String path;

  const ExploreCity({super.key, required this.name, required this.path});

  @override
  // ignore: library_private_types_in_public_api
  _ExploreCityState createState() => _ExploreCityState();
}

class _ExploreCityState extends State<ExploreCity> {
  late String icqa = '';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showAQIinfo(),
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
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
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('ICQA ',
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GradientBar(icqa: icqa),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ModelViewer(
                  debugLogging: true,
                  key: Key(widget.name),
                  src: 'assets/neighborhoods/${widget.path}',
                  autoRotate: true,
                  disableZoom: false,
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

  void showAQIinfo() {
    final List<String> icqaOptions = [
      'Bona',
      'Raonablement bona',
      'Regular',
      'Desfavorable',
      'Molt desfavorable',
      'Extremadament desfavorable'
    ];
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                  child: Text(translate("Air Quality"),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              for (int i = 0; i < icqaOptions.length; i++)
                _buildRow(
                  icqaOptions[i],
                  Icons.air,
                ),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(translate("Exit"))),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 5),
          Container(height: 2, color: const Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              const SizedBox(width: 16),
              Text(translate(name)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Icon(icon, color: getAirQualityColor(name)),
              ),
            ],
          ),
        ],
      ),
    );
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
}

double icqaToPercentage(String icqa) {
  switch (icqa) {
    case 'Bona':
      return 0.0;
    case 'Raonablement bona':
      return 0.15;
    case 'Regular':
      return 0.30;
    case 'Desfavorable':
      return 0.50;
    case 'Molt desfavorable':
      return 0.80;
    case 'Extremadament desfavorable':
      return 1.0;
    default:
      return 0.0;
  }
}

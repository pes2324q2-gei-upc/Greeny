import 'package:flutter/material.dart';

double punts = 0.5;

class CityPage extends StatefulWidget {
  const CityPage({Key? key}) : super(key: key);

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  int currentPageIndex = 0;
  double progressPercentage = 0.3;
  double punts = 0.5;

  void updateProgress(double newProgress) {
    setState(() {
      punts = newProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Julia's City",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BarraProgres(
                  punts: punts,
                  onProgressChanged: updateProgress,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: play,
                      icon: const Icon(Icons.play_arrow),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: viewHistory,
                      icon: const Icon(Icons.restore),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void play() {
    print('Playing');
  }

  void viewHistory() {
    print('Viewing history');
  }
}

class BarraProgres extends StatelessWidget {
  final double punts;
  final Function(double) onProgressChanged;

  const BarraProgres({
    required this.punts,
    required this.onProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 30.0),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.symmetric(horizontal: 110.0),
          child: Text('Nivell ${(punts * 100).toInt()}',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 5.0),
        Container(
          height: 23,
          margin: EdgeInsets.symmetric(horizontal: 100.0),
          child: LinearProgressIndicator(
            value: punts,
            backgroundColor: Color.fromARGB(255, 205, 197, 197),
            borderRadius: BorderRadius.circular(10.0),
            valueColor: AlwaysStoppedAnimation<Color>(
                const Color.fromARGB(255, 1, 167, 164)),
          ),
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(horizontal: 110.0),
          child: Text('Punts: ${(punts * 100).toStringAsFixed(1)}/100',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}

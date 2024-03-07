import 'package:flutter/material.dart';

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('City'),
            Container(
              width: 70,
              height: 70,
              margin:
                  EdgeInsets.all(8.0), // Ajusta el margen según tus necesidades
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.0),
                color: const Color.fromARGB(255, 1, 167,
                    164), // Cambia el color del fondo redondeado aquí
              ),

              child: IconButton(
                onPressed: play,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                iconSize: 40.0,
              ),
            ),
            BarraProgres(),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Greeny'),
        leading: IconButton(
            onPressed: viewHistory,
            icon: const Icon(Icons.restore),
            color: const Color.fromARGB(255, 1, 167, 164)),
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

class BarraProgres extends StatefulWidget {
  @override
  _BarraProgresState createState() => _BarraProgresState();
}

class _BarraProgresState extends State<BarraProgres> {
  double progres = 0.5;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: progres,
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue), // Ajusta el color de la barra de progreso aquí
        ),
        SizedBox(height: 10.0),
        Text('Progreso: ${(progres * 100).toStringAsFixed(1)}%'),
      ],
    );
  }
}

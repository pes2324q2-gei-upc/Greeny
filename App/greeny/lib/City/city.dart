import 'dart:math';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

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
              margin: const EdgeInsets.all(10.0),
              width: 300,
              height: 300,
              child: Stack(
                children: [
                  Opacity(
                    opacity: min(75,100-50)/100, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                    child: Image.asset('assets/cities/fog.png'),
                  ),
                  const ModelViewer(
                    key: Key('cityModelViewer'),
                    src: 'assets/cities/city_1.glb',
                    autoRotate: true,
                    disableZoom: true, 
                    rotationPerSecond: "25deg", // Rota 30 grados por segundo
                    autoRotateDelay: 1000, // Espera 1 segundos antes de rotar
                    cameraControls: false, // Evita que el usuario controle la cámara (true por defecto)
                  ),
                  Opacity(
                    opacity: min(75,100-50)/100, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                    child: Image.asset('assets/cities/fog.png'),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: play, icon: const Icon(Icons.play_arrow)),
            IconButton(onPressed: viewHistory, icon: const Icon(Icons.restore))
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

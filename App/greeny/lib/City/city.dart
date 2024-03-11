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
                  const ModelViewer(
                    src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                    autoRotate: true,
                    disableZoom: true,
                    disableTap: true, 
                    rotationPerSecond: "25deg", // Rota 30 grados por segundo
                    autoRotateDelay: 1000, // Espera 1 segundos antes de rotar
                    cameraControls: true, // Permite al usuario controlar la cámara (true por defecto)
                  ),
                  Opacity(
                    opacity: min(85,25)/100, // //min(85, puntuació_jugador)/puntuació_màxima_ciutat
                    child: Image.network('https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/f427aa69-f12a-4aa6-9d4a-cc7ae32a9fc0/d637xrm-d8a0b633-59fb-4e52-b911-db6b2fdc2a86.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2Y0MjdhYTY5LWYxMmEtNGFhNi05ZDRhLWNjN2FlMzJhOWZjMFwvZDYzN3hybS1kOGEwYjYzMy01OWZiLTRlNTItYjkxMS1kYjZiMmZkYzJhODYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.WOOjun5ZErQKwcm9KmT9_KqHYKANEIGCbOrkf9L8pfg'),
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

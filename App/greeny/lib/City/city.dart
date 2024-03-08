import 'dart:async';
//import 'dart:html'; HO HE HAGUT DE TREURE NO SE PERQUE

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

double punts = 0.5;

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  int currentPageIndex = 0;
  bool isPlaying = false;
  late Timer timer;

  @override
  Widget build(BuildContext context) {
    //comprovarUbicacio();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('City'),
            BarraProgres(punts: punts, onProgressChanged: updateProgress),
            Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.0),
                color: const Color.fromARGB(255, 1, 167, 164),
              ),
              child: IconButton(
                onPressed: () async {
                  if (isPlaying) {
                    // Si está reproduciendo, pausar
                    pause();
                  } else {
                    bool ubiActiva = await comprovarUbicacio();
                    if (!ubiActiva) return;
                    // Si no está reproduciendo, reproducir
                    play();
                    timer = Timer.periodic(Duration(seconds: 1), (timer) async {
                      await incrementPoints();
                      await getLocation();
                    });
                  }
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 40.0,
              ),
            ),
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
    setState(() {
      isPlaying = true;
    });
    print('Playing');
  }

  void pause() {
    setState(() {
      isPlaying = false;
    });
    print('Paused');
    timer.cancel(); //cancelar el temporitzador
  }

  void viewHistory() {
    print('Viewing history');
  }

  void updateProgress(double newProgress) {
    setState(() {
      punts = newProgress;
    });
  }

  Future<bool> comprovarUbicacio() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        print('Servicio no habilitado');
        return false;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Permiso denegado');
        return false;
      }
    }

    print('Servicio habilitado y permiso concedido');
    return true;
  }

  Future<void> incrementPoints() async {
    setState(() {
      if (punts < 1) {
        punts += 0.01;
        updateProgress(punts + 0.01);
      } else {
        punts = 0;
        updateProgress(punts);
      }
    });
  }

  Future<void> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    } catch (e) {
      print('Error obtaining location: $e');
      // Puedes manejar el error de manera adecuada según tus necesidades
    }
  }
}

// Barra de progres ciutat
class BarraProgres extends StatelessWidget {
  final double punts;
  final Function(double) onProgressChanged;

  const BarraProgres({required this.punts, required this.onProgressChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 30.0),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.symmetric(horizontal: 110.0),
          child: Text('Nivell ${(1)}'),
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
          child: Text('Punts: ${(punts * 100).toStringAsFixed(1)}/100'),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}

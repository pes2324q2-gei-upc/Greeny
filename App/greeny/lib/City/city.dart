import 'dart:async';
//import 'dart:html'; HO HE HAGUT DE TREURE NO SE PERQUE

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/appState.dart';
import 'package:provider/provider.dart';

double punts = 0.5;

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> with TickerProviderStateMixin {
  int currentPageIndex = 0;
  late AppState appState; // estat de l'aplicació
  late AnimationController
      _controller; // controlador per l'animació del botó play/pause
  late StreamSubscription<Position>
      positionStream; // stream de posicions per actualitzar l'ubicació
  static double km = 0; // km totals del recorregut actual o finalitzat
  Position? previousPosition; // posicio anterior per calcular els km desplaçats

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this); //inicialitzar el animation controller
    super.initState();
    previousPosition = null;
    appState = context.read<AppState>(); // estat de l'aplicació
  }

  @override
  void dispose() {
    _controller.dispose(); // per tancar el animation controller
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('City'),
            if (!appState.isPlaying)
              BarraProgres(punts: punts, onProgressChanged: updateProgress),
            if (appState.isPlaying)
              Icon(Icons.directions_walk,
                  size: 50), // icona per indicar que sésta fent un recorregut
            if (appState.isPlaying)
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 110.0),
                child: Text(
                  'Km recorreguts: ${(km).toStringAsFixed(2)} km',
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontWeightDelta: 4, fontSizeFactor: 2.0),
                  textAlign: TextAlign.center,
                ), //imprimeix els km de lib/City/comptakm.dart
              ),
            SizedBox(height: 20.0),
            buildplaypause(),
            if (!appState.isPlaying)
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 110.0),
                child: Text(
                  'Ultim recorregut: ${(km).toStringAsFixed(2)} km',
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontWeightDelta: 2),
                  textAlign: TextAlign.center,
                ), //imprimeix els km de lib/City/comptakm.dart
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Greeny',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: viewHistory,
            icon: const Icon(Icons.restore),
            color: const Color.fromARGB(255, 1, 167, 164)),
      ),
    );
  }

  // inicia el comptador de km i pasa al estat isPlaying true
  void play() {
    _controller.forward();
    setState(() {
      km = 0;
      appState.isPlaying = true;
    });
    startLocationUpdates();
    print('Playing');
  }

  //pausa el comptador de km i pasa al estat isPlaying false
  void pause() {
    _controller.reverse();
    positionStream.cancel();
    setState(() {
      previousPosition = null;
      appState.isPlaying = false;
    });
    print('Paused');
  }

  void viewHistory() {
    print('Viewing history');
  }

  // actualitza els punts per newProgress
  void updateProgress(double newProgress) {
    setState(() {
      punts = newProgress;
    });
  }

//incrementa punts de la barra de progrés per provar-la
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

  // Boto animat de play/pause
  Widget buildplaypause() {
    return Container(
      width: 70,
      height: 70,
      margin: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.0),
        color: const Color.fromARGB(255, 1, 167, 164),
      ),
      child: GestureDetector(
        onTap: () async {
          if (appState.isPlaying) {
            // Si está reproduciendo, pausar
            pause();
          } else {
            bool ubiActiva = await comprovarUbicacio();
            if (!ubiActiva) return;
            // Si no está reproduciendo, reproducir
            play();
          }
        },
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _controller,
          size: 50.0,
          color: Colors.white,
        ),
      ),
    );
  }

  // crea un stream d'ubicacions i cada cop que canvia l'ubicació actualitza el comptador de km
  Future<void> startLocationUpdates() async {
    // ignore: unused_local_variable
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
    ).listen((Position position) {
      if (previousPosition != null) {
        double distanceInMeters = Geolocator.distanceBetween(
          previousPosition!.latitude,
          previousPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // Convertir la distancia de metros a kilómetros y actualizar el contador.
        double distanceInKm = distanceInMeters / 1000;
        km += distanceInKm;
        //print(km); //chivato per comprovar els km
        setState(() {}); //actualizar la interfaz
      }
      previousPosition = position;
    });
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
          child: Text('Nivell ${(1)}',
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

/* Future<void> getLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  } catch (e) {
    print('Error obtaining location: $e');
  }
} */

// comprova que els servieis dúbicació estan activats i tenen permissos
Future<bool> comprovarUbicacio() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await Geolocator.openLocationSettings();
    if (!serviceEnabled) {
      print('Servei ubicació no habilitat');
      return false;
    }
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      print('Permis denegat');
      return false;
    }
  }

  print('Servei habilitat i permis otorgat');
  return true;
}

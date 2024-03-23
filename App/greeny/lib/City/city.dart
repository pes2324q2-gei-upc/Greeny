import 'dart:math';

import 'dart:async';
//import 'dart:html'; HO HE HAGUT DE TREURE NO SE PERQUE

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/City/LocationService.dart';
import 'package:greeny/appState.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'form_final.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
  Timer? _updateTimer;

  double progressPercentage = 0.3;
  double punts = 50.0;
  double levelPoints = 100.0;
  String level = 'Nivell 1 - Nou Barris';
  @override
  void initState() {
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    super.initState();
    appState = context.read<AppState>(); // estat de l'aplicació
    if (appState.isPlaying) {
      _updateTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // per tancar el animation controller
    _updateTimer?.cancel();
    super.dispose();
  }

  void updateProgress(double newProgress) {
    setState(() {
      punts = newProgress;
    });

    if (punts <= 0) {
      setState(() {
        level = 'Nivell 1 - Nou Barris';
        punts = 0;
      });
    } else if (punts > 100 && level == 'Nivell 1 - Nou Barris') {
      setState(() {
        levelPoints = 200.0;
        level = 'Nivell 2 - Horta-Guinardó';
        punts = 0;
      });
    } else if (punts > 200 && level == 'Nivell 2 - Horta-Guinardó') {
      setState(() {
        level = 'Nivell 3 - Sants-Montjuïc';
        levelPoints = 400.0;
        punts = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30.0),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              child: Stack(
                children: [
                  Opacity(
                    opacity: max(
                            min(75, 100 - (punts / levelPoints) * 100), 0) /
                        100, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                    child: Image.asset('assets/cities/fog.png'),
                  ),
                  if (level == 'Nivell 1 - Nou Barris')
                    const ModelViewer(
                      key: Key('cityModelViewer'),
                      src: 'assets/cities/city_1.glb',
                      autoRotate: true,
                      disableZoom: true,
                      rotationPerSecond: "25deg", // Rota 30 grados por segundo
                      autoRotateDelay: 1000, // Espera 1 segundos antes de rotar
                      cameraControls:
                          false, // Evita que el usuario controle la cámara (true por defecto)
                    ),
                  if (level == 'Nivell 2 - Horta-Guinardó')
                    const ModelViewer(
                      key: Key('city2ModelViewer'),
                      src: 'assets/cities/Horta-Guinardo.glb',
                      autoRotate: true,
                      disableZoom: true,
                      rotationPerSecond: "25deg", // Rota 30 grados por segundo
                      autoRotateDelay: 1000, // Espera 1 segundos antes de rotar
                      cameraControls:
                          false, // Evita que el usuario controle la cámara (true por defecto)
                    ),
                  if (level == 'Nivell 3 - Sants-Montjuïc')
                    const ModelViewer(
                      key: Key('city3ModelViewer'),
                      src: 'assets/cities/Sants-Montjuic.glb',
                      autoRotate: true,
                      disableZoom: true,
                      rotationPerSecond: "25deg", // Rota 30 grados por segundo
                      autoRotateDelay: 1000, // Espera 1 segundos antes de rotar
                      cameraControls:
                          false, // Evita que el usuario controle la cámara (true por defecto)
                    ),
                  Opacity(
                    opacity: max(
                            min(75, 100 - (punts / levelPoints) * 100), 0) /
                        100, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                    child: Image.asset('assets/cities/fog.png'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            if (!appState.isPlaying)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BarraProgres(
                    punts: punts,
                    onProgressChanged: updateProgress,
                    levelPoints: levelPoints,
                    level: level,
                  ),
                ],
              ),
            if (appState.isPlaying)
              const Icon(Icons.directions_walk,
                  size: 30), // icona per indicar que sésta fent un recorregut
            if (appState.isPlaying) KmTravelled(km: appState.totalDistance),
            buildplaypause(),
            if (!appState.isPlaying) LastTravel(km: appState.totalDistance),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    color: const Color.fromARGB(255, 1, 167, 164),
                  ),
                  child: IconButton(
                    onPressed: removePoints,
                    color: Colors.white,
                    icon: const Icon(Icons.remove),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    color: const Color.fromARGB(255, 1, 167, 164),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: addPoints,
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: const Text(
          'Julia\'s City',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),    
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
      appState.totalDistance = 0;
      appState.isPlaying = true;
    });
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      // Actualizar el widget KmTravelled con la distancia actualizada
      setState(() {});
    });
    LocationService.instance.startLocationUpdates(context);
  }

  //pausa el comptador de km i pasa al estat isPlaying false
  void pause() {
    _controller.reverse();
    LocationService.instance.stopLocationUpdates(context);
    _updateTimer?.cancel();
    setState(() {
      appState.isPlaying = false;
      finalForm();
    });
  }

  void viewHistory() {
    print('Viewing history');
  }

  void finalForm() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              FormFinalPage(totalDistance: appState.totalDistance)),
      (route) => false,
    );
  }

  // Boto animat de play/pause
  Widget buildplaypause() {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
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
        child: appState.isPlaying
            ? const Icon(
                Icons.pause,
                key: Key('pause_icon_key'),
                size: 30.0,
                color: Colors.white,
              )
            : const Icon(
                Icons.play_arrow,
                key: Key('play_icon_key'),
                size: 30.0,
                color: Colors.white,
              ),
      ),
    );
  }

  void addPoints() {
    setState(() {
      punts += 10;
    });
    updateProgress(
        punts); // Llama a la función para actualizar la barra de progreso
    print(punts);
  }

  void removePoints() {
    setState(() {
      punts -= 10;
    });
    updateProgress(
        punts); // Llama a la función para actualizar la barra de progreso
    print(punts);
  }
}

class LastTravel extends StatelessWidget {
  const LastTravel({
    super.key,
    required this.km,
  });

  final double km;

  @override
  Widget build(BuildContext context) {
    var translatedtext = translate('Last travel: ');
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Text(
        "$translatedtext ${(km).toStringAsFixed(2)} km",
        style: DefaultTextStyle.of(context).style.apply(fontWeightDelta: 2),
        textAlign: TextAlign.center,
      ), //imprimeix els km de lib/City/comptakm.dart
    );
  }
}

class KmTravelled extends StatelessWidget {
  const KmTravelled({
    super.key,
    required this.km,
  });

  final double km;

  @override
  Widget build(BuildContext context) {
    var translatedtext = translate('Km travelled: ');
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 110.0),
      child: Text(
        "$translatedtext ${(km).toStringAsFixed(2)} km",
        style: DefaultTextStyle.of(context)
            .style
            .apply(fontWeightDelta: 4, fontSizeFactor: 1.0),
        textAlign: TextAlign.center,
      ), //imprimeix els km de lib/City/comptakm.dart
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
      return false;
    }
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return false;
    }
  }

  return true;
}

class BarraProgres extends StatelessWidget {
  final double punts;
  final Function(double) onProgressChanged;
  final double levelPoints;
  final String level;

  const BarraProgres({super.key, 
    required this.punts,
    required this.onProgressChanged,
    required this.levelPoints,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * 0.7, // 70% del ancho disponible
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(horizontal: 110.0),
              child: Text(
                level,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        const SizedBox(height: 5.0),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 23,
              width: constraints.maxWidth * 0.7, // 70% del ancho disponible
              margin: const EdgeInsets.symmetric(horizontal: 100.0),
              child: LinearProgressIndicator(
                value: punts / levelPoints,
                backgroundColor: const Color.fromARGB(255, 205, 197, 197),
                borderRadius: BorderRadius.circular(10.0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                   Color.fromARGB(255, 1, 167, 164),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 5.0),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * 0.7, // 70% del ancho disponible
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 110.0),
              child: Text(
                'Punts: ${(punts).toStringAsFixed(1)}/$levelPoints',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}

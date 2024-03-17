import 'dart:math';

import 'dart:async';
//import 'dart:html'; HO HE HAGUT DE TREURE NO SE PERQUE

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/City/LocationService.dart';
import 'package:greeny/appState.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class CityPage extends StatefulWidget {
  const CityPage({Key? key}) : super(key: key);

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

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this); //inicialitzar el animation controller
    super.initState();
    appState = context.read<AppState>(); // estat de l'aplicació
    if (appState.isPlaying) {
      _updateTimer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
        // Actualizar el widget KmTravelled con la distancia actualizada
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
      this.punts = newProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    onPressed: addPoints,
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const Text(
              "Julia's City",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              child: Stack(
                children: [
                  Opacity(
                    opacity: min(75, 100 - punts) /
                        100, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                    child: Image.asset('assets/cities/fog.png'),
                  ),
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
                  Opacity(
                    opacity: min(75, 100 - punts) /
                        100, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                    child: Image.asset('assets/cities/fog.png'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),

            if (!appState.isPlaying)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BarraProgres(
                    punts: punts,
                    onProgressChanged: updateProgress,
                  ),
                ],
              ),
            if (appState.isPlaying)
              const Icon(Icons.directions_walk,
                  size: 30), // icona per indicar que sésta fent un recorregut
            if (appState.isPlaying) KmTravelled(km: appState.totalDistance),
            buildplaypause(),
            if (!appState.isPlaying) LastTravel(km: appState.totalDistance),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: const Text(
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
      appState.totalDistance = 0;
      appState.isPlaying = true;
    });
    _updateTimer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      // Actualizar el widget KmTravelled con la distancia actualizada
      setState(() {});
    });
    LocationService.instance.startLocationUpdates(context);
    print('Playing');
  }

  //pausa el comptador de km i pasa al estat isPlaying false
  void pause() {
    _controller.reverse();
    LocationService.instance.stopLocationUpdates(context);
    _updateTimer?.cancel();
    setState(() {
      appState.isPlaying = false;
    });
    print('Paused');
  }

  void viewHistory() {
    print('Viewing history');
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
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Text(
        'Últim recorregut: ${(km).toStringAsFixed(2)} km',
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
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 110.0),
      child: Text(
        'Km recorreguts: ${(km).toStringAsFixed(2)} km',
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
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * 0.7, // 70% del ancho disponible
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 110.0),
              child: Text(
                'Nivell 1',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        SizedBox(height: 5.0),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 23,
              width: constraints.maxWidth * 0.7, // 70% del ancho disponible
              margin: EdgeInsets.symmetric(horizontal: 100.0),
              child: LinearProgressIndicator(
                value: punts / 100,
                backgroundColor: Color.fromARGB(255, 205, 197, 197),
                borderRadius: BorderRadius.circular(10.0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color.fromARGB(255, 1, 167, 164),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 5.0),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * 0.7, // 70% del ancho disponible
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: 110.0),
              child: Text(
                'Punts: ${(punts).toStringAsFixed(1)}/100',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}

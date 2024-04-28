import 'dart:math';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/City/location_service.dart';
import 'package:greeny/City/history.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/app_state.dart';
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

  int punts = 0;
  int levelPoints = 100;
  String nhoodName = 'Nou Barris';

  String userName = '';

  @override
  void initState() {
    obtenirNomUsuari();
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

  obtenirNomUsuari() async {
    userName = await UserAuth().readUserInfo('name');
    setState(() {
      userName = userName;
    });
  }

  void updateProgress(int newProgress) {
    setState(() {
      punts = newProgress;
    });

    if (punts <= 0) {
      setState(() {
        nhoodName = 'Nou Barris';
        punts = 0;
      });
    } else if (punts > 100 && nhoodName == 'Nou Barris') {
      setState(() {
        levelPoints = 200;
        nhoodName = 'Horta-Guinardó';
        punts = 0;
      });
    } else if (punts > 200 && nhoodName == 'Horta-Guinardó') {
      setState(() {
        nhoodName = 'Sants-Montjuïc';
        levelPoints = 400;
        punts = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userName == '') {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 220, 255, 255),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      double opct = max(min(75, 100 - (punts / levelPoints) * 100), 0) / 100;
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        body: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('$userName\'s City',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25.0)),
                    const SizedBox(height: 20),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.9,
                        child: Stack(
                          children: [
                            Opacity(
                              opacity:
                                  opct /*max(min(75, 100 - (punts / levelPoints) * 100),0) / 100*/, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                              child: Image.asset(opct > 0.66
                                  ? 'assets/neighborhoods/fog1.png'
                                  : opct > 0.33
                                      ? 'assets/neighborhoods/fog2.png'
                                      : 'assets/neighborhoods/fog3.png'),
                            ),
                            const ModelViewer(
                              debugLogging: false,
                              key: Key('cityModelViewer'),
                              src: 'assets/neighborhoods/nhood_1.glb',
                              autoRotate: true,
                              disableZoom: true,
                              rotationPerSecond:
                                  "25deg", // Rota 30 grados por segundo
                              autoRotateDelay:
                                  1000, // Espera 1 segundos antes de rotar
                              cameraControls:
                                  false, // Evita que el usuario controle la cámara (true por defecto)
                            ),
                            Opacity(
                              opacity:
                                  opct /*max(min(75, 100 - (punts / levelPoints) * 100),0) / 100*/, // //min(75, puntuació_màxima_ciutat-puntuació_jugador)/puntuació_màxima_ciutat
                              child: Image.asset(opct > 0.66
                                  ? 'assets/neighborhoods/fog1.png'
                                  : opct > 0.33
                                      ? 'assets/neighborhoods/fog2.png'
                                      : 'assets/neighborhoods/fog3.png'),
                            ),
                          ],
                        )),
                    const SizedBox(height: 20),
                    if (!appState.isPlaying)
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: Column(
                          children: [
                            BarraProgres(
                              punts: punts,
                              onProgressChanged: updateProgress,
                              levelPoints: levelPoints,
                              nhoodName: nhoodName,
                            ),
                            buildplaypause(),
                            if (appState.totalDistance != 0)
                              LastTravel(km: appState.totalDistance),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                          height: 300,
                          width: 300,
                          child: Column(children: [
                            KmTravelled(km: appState.totalDistance),
                            const SizedBox(height: 10),
                            buildplaypause(),
                          ])),
                  ],
                ),
              ),
            ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          leading: IconButton(
              onPressed: viewHistory,
              icon: const Icon(Icons.restore),
              color: const Color.fromARGB(255, 1, 167, 164)),
          actions: [
            IconButton(
              onPressed: () {
                addPoints();
              },
              icon: const Icon(Icons.add),
              color: const Color.fromARGB(255, 1, 167, 164),
            ),
            IconButton(
              onPressed: () {
                removePoints();
              },
              icon: const Icon(Icons.remove),
              color: const Color.fromARGB(255, 1, 167, 164),
            ),
          ],
        ),
      );
    }
  }

  // inicia el comptador de km i pasa al estat isPlaying true
  void play() {
    _controller.forward();
    setState(() {
      appState.totalDistance = 0;
      appState.isPlaying = true;
      appState.startedAt = DateTime.now();
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HistoryPage()));
  }

  void finalForm() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => FormFinalPage(
              totalDistance: appState.totalDistance,
              startedAt: appState.startedAt!)),
      (route) => false,
    );
  }

  // Boto animat de play/pause
  Widget buildplaypause() {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
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
                size: 40.0,
                color: Colors.white,
              )
            : const Icon(
                Icons.play_arrow,
                key: Key('play_icon_key'),
                size: 40.0,
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
  }

  void removePoints() {
    setState(() {
      punts -= 10;
    });
    updateProgress(
        punts); // Llama a la función para actualizar la barra de progreso
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
    var translatedtext = translate('Previous travel: ');
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
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
      margin: const EdgeInsets.all(10),
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
  final int punts;
  final Function(int) onProgressChanged;
  final int levelPoints;
  final String nhoodName;

  const BarraProgres({
    super.key,
    required this.punts,
    required this.onProgressChanged,
    required this.levelPoints,
    required this.nhoodName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.8, // Establecer el ancho del contenedor
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                alignment: Alignment.centerRight,
                //margin: const EdgeInsets.symmetric(horizontal: 110.0),
                child: Text(
                  nhoodName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const SizedBox(height: 5.0),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 23,
                //margin: const EdgeInsets.symmetric(horizontal: 100.0),
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
                alignment: Alignment.centerLeft,
                // margin: const EdgeInsets.symmetric(
                //     horizontal: MediaQuery.of(context).size.width * 0.1),
                child: Text(
                  'Punts: $punts/$levelPoints',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}

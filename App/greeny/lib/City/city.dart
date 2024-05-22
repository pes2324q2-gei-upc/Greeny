import 'dart:math';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/City/location_service.dart';
import 'package:greeny/City/history.dart';
import 'package:greeny/utils/app_state.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'form_final.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'dart:convert';

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

  int userPoints = 0;
  int levelPoints = 100;
  int levelNumber = 1;
  String nhoodName = '';
  String nhoodPath = '';
  bool allCompleted = false;

  String userName = '';
  bool isStaff = false;

  ValueNotifier<Map<String, dynamic>?> cityDataNotifier = ValueNotifier(null);
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    appState = context.read<AppState>(); // estat de l'aplicació
    if (appState.isPlaying) {
      _updateTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        setState(() {});
      });
    }
    getCityData().then((newCityData) {
      setState(() {
        cityDataNotifier.value = newCityData;
        userName = newCityData['user_name'];
        isStaff = newCityData['is_staff'];
        allCompleted = newCityData.containsKey('status') &&
            newCityData['status'] == 'all_completed';
        if (!allCompleted) {
          userPoints = newCityData['points_user'];
          levelPoints = newCityData['points_total'];
          levelNumber = newCityData['number'];
          nhoodName = newCityData['neighborhood']['name'];
          nhoodPath = newCityData['neighborhood']['path'];
        }
      });
    });
  }

  Future<Map<String, dynamic>> getCityData() async {
    final response = await httpGet('/api/city/');

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load city data');
    }
  }

  Future<void> updateCityData(int points) async {
    final response = await httpPut(
      '/api/city/',
      jsonEncode({'points_user': points}),
    );
    print("put ejecutado");
    if (response.statusCode == 200) {
      Map<String, dynamic> newCityData =
          jsonDecode(utf8.decode(response.bodyBytes));
      print(newCityData);
      if (newCityData.containsKey('status') &&
          newCityData['status'] == 'all_completed') {
        setState(() {
          cityDataNotifier.value =
              newCityData; // Actualiza los datos notificados
          allCompleted = true; // Marca que todos los niveles están completados
          userPoints = points; // Actualiza los puntos del usuario

          // Actualiza los datos del usuario y el estado de staff si están disponibles
          userName = newCityData['user_name'] ??
              userName; // Utiliza el operador ?? para mantener el valor anterior si no viene uno nuevo
          isStaff = newCityData['is_staff'] ?? isStaff;
        });
      } else {
        setState(() {
          cityDataNotifier.value = newCityData;
          userPoints = newCityData['points_user'];
          levelPoints = newCityData['points_total'];
          levelNumber = newCityData['number'];
          nhoodName = newCityData['neighborhood']['name'];
          nhoodPath = newCityData['neighborhood']['path'];
        });
      }
    } else {
      throw Exception('Failed to update city data');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // per tancar el animation controller
    _updateTimer?.cancel();
    super.dispose();
  }

  void updateProgress(int points) async {
    await updateCityData(points);
  }

  @override
  Widget build(BuildContext context) {
    if (userName == '') {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 220, 255, 255),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      double opct = max(min(0.75, 1.0 - (userPoints / levelPoints)), 0.0);
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
                            ValueListenableBuilder<Map<String, dynamic>?>(
                              valueListenable: cityDataNotifier,
                              builder: (BuildContext context,
                                  Map<String, dynamic>? cityData,
                                  Widget? child) {
                                if (cityData == null) {
                                  // Los datos aún no están disponibles, muestra un indicador de carga.
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  );
                                } else {
                                  if (cityData.containsKey('status') &&
                                      cityData['status'] == 'all_completed') {
                                    // Todos los niveles están completados, muestra un botón de reinicio.
                                    return Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Aquí puedes poner la lógica para reiniciar los niveles.
                                        },
                                        child: const Text('Restart'),
                                      ),
                                    );
                                  } else {
                                    // Los datos están disponibles, construye el ModelViewer y las imágenes de niebla.
                                    userPoints = cityData['points_user'];
                                    levelPoints = cityData['points_total'];
                                    levelNumber = cityData['number'];
                                    nhoodName =
                                        cityData['neighborhood']['name'];
                                    nhoodPath =
                                        cityData['neighborhood']['path'];

                                    return Stack(
                                      children: [
                                        Opacity(
                                          opacity:
                                              opct, // Calcula la opacidad basada en los puntos
                                          child: Image.asset(opct > 0.66
                                              ? 'assets/neighborhoods/fog1.png'
                                              : opct > 0.33
                                                  ? 'assets/neighborhoods/fog2.png'
                                                  : 'assets/neighborhoods/fog3.png'),
                                        ),
                                        ModelViewer(
                                          debugLogging: false,
                                          key: Key(nhoodName),
                                          src:
                                              'assets/neighborhoods/$nhoodPath',
                                          autoRotate: true,
                                          disableZoom: true,
                                          rotationPerSecond: "25deg",
                                          autoRotateDelay: 1000,
                                          cameraControls: false,
                                        ),
                                        Opacity(
                                          opacity:
                                              opct, // Repite la opacidad para la segunda imagen de niebla
                                          child: Image.asset(opct > 0.66
                                              ? 'assets/neighborhoods/fog1.png'
                                              : opct > 0.33
                                                  ? 'assets/neighborhoods/fog2.png'
                                                  : 'assets/neighborhoods/fog3.png'),
                                        ),
                                      ],
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        )),
                    const SizedBox(height: 20),
                    if (!appState.isPlaying && !allCompleted)
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: Column(
                          children: [
                            BarraProgres(
                              userPoints: userPoints,
                              onProgressChanged: updateProgress,
                              levelPoints: levelPoints,
                              nhoodName: nhoodName,
                              levelNumber: levelNumber,
                            ),
                            buildplaypause(),
                            if (appState.totalDistance != 0)
                              LastTravel(km: appState.totalDistance),
                          ],
                        ),
                      )
                    else if (!allCompleted)
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
          actions: isStaff
              ? [
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
                ]
              : [],
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
    updateProgress(userPoints +
        50); // Llama a la función para actualizar la barra de progreso
  }

  void removePoints() {
    updateProgress(userPoints -
        50); // Llama a la función para actualizar la barra de progreso
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
  final int userPoints;
  final Function(int) onProgressChanged;
  final int levelPoints;
  final String nhoodName;
  final int levelNumber;

  const BarraProgres({
    super.key,
    required this.userPoints,
    required this.onProgressChanged,
    required this.levelPoints,
    required this.nhoodName,
    required this.levelNumber,
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
                  "Nivell $levelNumber - $nhoodName",
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
                  value: userPoints / levelPoints,
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
                  'Punts: $userPoints/$levelPoints',
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

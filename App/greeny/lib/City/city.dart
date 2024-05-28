import 'dart:math';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greeny/City/history.dart';
import 'package:greeny/City/location_service.dart';
import 'package:greeny/utils/app_state.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'form_final.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'dart:convert';
import 'package:greeny/utils/utils.dart';

import 'package:greeny/utils/onboarding_page.dart';

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
  String previousNhoodName = '';
  String previousLevelName = '';
  int previousLevelNumber = -1;
  bool allCompleted = false;
  int mastery = 1;
  bool previousLevelJustPassed = false;
  String userName = '';
  bool isStaff = false;

  bool _showModelViewer = true;

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
    getCityData();
  }

  Future<void> getCityData() async {
    final response = await httpGet('/api/city/');

    if (response.statusCode == 200) {
      var newCityData = jsonDecode(utf8.decode(response.bodyBytes));
      if (newCityData != null) {
        setState(() {
          cityDataNotifier.value = newCityData;
          userName = newCityData['user_name'];
          isStaff = newCityData['is_staff'];
          allCompleted = newCityData.containsKey('status') &&
              newCityData['status'] == 'all_completed';

          if (newCityData['neighborhood'] != null) {
            String newNhoodName = newCityData['neighborhood']['name'];
            String newPath = newCityData['neighborhood']['path'];
            if (!allCompleted) {
              nhoodName = newNhoodName;
              nhoodPath = newPath;
            } else {
              nhoodName = "all_nhoods";
              nhoodPath = "all_nhoods.glb";
            }
          }

          previousLevelJustPassed = newCityData['previous_lvl_just_passed'];
          if (newCityData['previous_level_name'] != null) {
            previousLevelName = newCityData['previous_level_name'];
          }
          if (!allCompleted) {
            userPoints = newCityData['points_user'];
            levelPoints = newCityData['points_total'];
            levelNumber = newCityData['number'];
          }
        });
        if (previousLevelJustPassed) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/neighborhoods/green_leafs.webp', // Reemplaza esto con la ruta de tu ícono
                        width: 24, // Puedes ajustar el tamaño como necesites
                        height: 24, // Puedes ajustar el tamaño como necesites
                      ),
                      const SizedBox(width: 10),
                      Text(translate('Congratulations!')),
                    ],
                  ),
                  content: Text(
                      translate('You have decontaminated the district of ') +
                          previousLevelName +
                          translate(', your city is now more Greeny!')),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } else {
      // ignore: use_build_context_synchronously
      showMessage(context, translate('Failed to load city data'));
    }
  }

  Future<void> updateCityData(int points) async {
    final response = await httpPut(
        '/api/city/', jsonEncode({'points_user': points}), 'application/json'
        // Add the missing positional argument
        );
    if (response.statusCode == 200) {
      Map<String, dynamic> newCityData =
          jsonDecode(utf8.decode(response.bodyBytes));
      if (newCityData.containsKey('status') &&
          newCityData['status'] == 'all_completed') {
        setState(() {
          cityDataNotifier.value =
              newCityData; // Actualiza los datos notificados
          allCompleted = true; // Marca que todos los niveles están completados
          userPoints = 0; // Actualiza los puntos del usuario
          nhoodName = "all_nhoods";
          nhoodPath = "all_nhoods.glb";
          // Actualiza los datos del usuario y el estado de staff si están disponibles
          userName = newCityData['user_name'] ??
              userName; // Utiliza el operador ?? para mantener el valor anterior si no viene uno nuevo
          isStaff = newCityData['is_staff'] ?? isStaff;
          mastery = newCityData['mastery'] ?? mastery;
        });
      } else {
        setState(() {
          previousLevelNumber = levelNumber;
          previousNhoodName = nhoodName;
          cityDataNotifier.value = newCityData;
          userPoints = newCityData['points_user'];
          levelPoints = newCityData['points_total'];
          levelNumber = newCityData['number'];
          nhoodName = newCityData['neighborhood']['name'];
          nhoodPath = newCityData['neighborhood']['path'];

          if (levelNumber > previousLevelNumber) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/neighborhoods/green_leafs.webp', // Reemplaza esto con la ruta de tu ícono
                        width: 24, // Puedes ajustar el tamaño como necesites
                        height: 24, // Puedes ajustar el tamaño como necesites
                      ),
                      const SizedBox(width: 10),
                      Text(translate('Congratulations!')),
                    ],
                  ),
                  content: Text(
                      translate('You have decontaminated the district of ') +
                          previousNhoodName +
                          translate(', your city is now more Greeny!')),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        });
      }
    } else {
      throw Exception('Failed to update city data');
    }
  }

  Future<void> resetLevels() async {
    final response = await httpPut(
        '/api/city/', // Assuming '/api/city/reset' is the endpoint for resetting levels
        jsonEncode({
          'reset': true
        }), // Assuming your API requires a body to initiate reset
        'application/json' // Set the content type as JSON
        );

    if (response.statusCode == 200) {
      Map<String, dynamic> newCityData =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        cityDataNotifier.value =
            newCityData; // Update the data notifier with the reset response

        if (newCityData.containsKey('status') &&
            newCityData['status'] == 'levels_reset') {
          cityDataNotifier.value = newCityData;
          userPoints = newCityData['points_user'];
          levelPoints = newCityData['points_total'];
          levelNumber = newCityData['number'];
          nhoodName = newCityData['neighborhood']['name'];
          nhoodPath = newCityData['neighborhood']['path'];
          userName = newCityData['user_name'];
          isStaff = newCityData['is_staff'];
          allCompleted = false; // Mark all levels as not completed
        } else {
          throw Exception(
              'Failed to reset levels properly: Status not confirmed');
        }
      });
    } else {
      throw Exception('Failed to reset levels: ${response.statusCode}');
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

  String toRoman(int number) {
    // number must be 1, 2, 3 or 4.
    switch (number) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      default:
        return '';
    }
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
                    Text(translate('City of ') + userName,
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
                                if (cityData == null || !_showModelViewer) {
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
                                    var translatedtext1 =
                                        translate('Congratulations, you have');
                                    var translatedtext2 =
                                        translate('achieved Mastery ');
                                    var translatedtext3 =
                                        translate('Game restarted');
                                    var translatedtext4 =
                                        translate('Levels have been restarted');
                                    var translatedtext5 =
                                        translate('Restart game');
                                    return Stack(
                                      children: [
                                        Positioned(
                                          top: 5,
                                          left: 0,
                                          right: 0,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                translatedtext1,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    translatedtext2,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${toRoman(mastery + 1)} !',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        ModelViewer(
                                          debugLogging: false,
                                          key: Key(nhoodName),
                                          src:
                                              'assets/neighborhoods/all_nhoods.glb',
                                          autoRotate: true,
                                          disableZoom: true,
                                          rotationPerSecond: "25deg",
                                          autoRotateDelay: 1000,
                                          cameraControls: false,
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            // Asegura que el SizedBox esté centrado horizontalmente
                                            child: SizedBox(
                                              width:
                                                  200, // Establece el ancho del botón
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    await resetLevels();
                                                    showDialog(
                                                        // ignore: use_build_context_synchronously
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                translatedtext3),
                                                            content: Text(
                                                                translatedtext4),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                  child:
                                                                      const Text(
                                                                          "OK"))
                                                            ],
                                                          );
                                                        });
                                                    // ignore: empty_catches
                                                  } catch (e) {}
                                                },
                                                child: Text(translatedtext5),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
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
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
          actions: !allCompleted && isStaff
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
    setState(() {
      _showModelViewer = false;
    });

    /*Navigator.push(context,
        MaterialPageRoute(builder: (context) => const HistoryPage())).then((_) {
      setState(() {
        _showModelViewer = true;
      });
    });*/
    Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingPage()),
            (Route<dynamic> route) => false,
          );
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
            bool ubiActiva = await LocationService.instance.comprovarUbicacio();
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
    updateProgress(
        50); // Llama a la función para actualizar la barra de progreso
  }

  void removePoints() {
    updateProgress(
        -50); // Llama a la función para actualizar la barra de progreso
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
              var translatedtext = translate('Level');
              return Container(
                alignment: Alignment.centerRight,
                //margin: const EdgeInsets.symmetric(horizontal: 110.0),
                child: Text(
                  "$translatedtext $levelNumber - $nhoodName",
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
              var translatedtext = translate('Points:');
              return Container(
                alignment: Alignment.centerLeft,
                // margin: const EdgeInsets.symmetric(
                //     horizontal: MediaQuery.of(context).size.width * 0.1),
                child: Text(
                  '$translatedtext $userPoints/$levelPoints',
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

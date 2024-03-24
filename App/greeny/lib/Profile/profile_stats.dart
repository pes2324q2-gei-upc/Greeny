import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileStatsPage extends StatefulWidget {
  const ProfileStatsPage({super.key});

  @override
  State<ProfileStatsPage> createState() => _ProfileStatsPageState();
}

class _ProfileStatsPageState extends State<ProfileStatsPage> {
  double co2Saved = 0;
  double kmTotal = 0;
  double kmWalked = 0;
  double kmBiked = 0;
  double kmElectricCar = 0;
  double kmPublicTransport = 0;
  double kmBus = 0;
  double kmMotorcycle = 0;
  double kmCar = 0;

  @override
  void initState() {
    super.initState();
    getStats();
  }

  Future<void> getStats() async {
    Map<String, dynamic> statsData = {};
    var url = Uri.http(dotenv.env['BACKEND_URL']!,
        '/api/statistics/dummy'); //Canviar dummy pel nom de l'usuari
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        statsData = json.decode(response.body);
        co2Saved = statsData['kg_CO2'].toDouble();
        kmTotal = statsData['km_Totals'].toDouble();
        kmWalked = statsData['km_Walked'].toDouble();
        kmBiked = statsData['km_Biked'].toDouble();
        kmElectricCar = statsData['km_ElectricCar'].toDouble();
        kmPublicTransport = statsData['km_PublicTransport'].toDouble();
        kmBus = statsData['km_Bus'].toDouble();
        kmMotorcycle = statsData['km_Motorcycle'].toDouble();
        kmCar = statsData['km_Car'].toDouble();
      });
    } else {
      showMessage("Error loading statistics");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: (AppBar(
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          leading: IconButton(
            onPressed: share,
            icon: const Icon(Icons.ios_share),
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
          actions: [
            IconButton(
              onPressed: showSettings,
              icon: const Icon(Icons.settings),
              color: const Color.fromARGB(255, 1, 167, 164),
            ),
          ],
        )),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                const Text('Júlia',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)),
                SizedBox(
                    height:
                        MediaQuery.of(context).devicePixelRatio.toInt() * 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco,
                              size: 40.0,
                              color: Color.fromARGB(255, 1, 167, 164)),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$co2Saved kg',
                                  style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold)),
                              Text(translate('of CO2 saved'),
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          const Icon(Icons.route,
                              size: 40.0,
                              color: Color.fromARGB(255, 1, 167, 164)),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${kmTotal.toStringAsFixed(2)} kms',
                                  style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold)),
                              Text(translate('traveled'),
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height:
                        MediaQuery.of(context).devicePixelRatio.toInt() * 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(translate('PERCENTAGE OF USE'),
                            style: const TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      children: [
                        ProgressBar(
                            icon: Icons.directions_walk,
                            percentage: kmTotal != 0 ? kmWalked / kmTotal : 0),
                        const SizedBox(height: 5),
                        ProgressBar(
                            icon: Icons.directions_bike,
                            percentage: kmTotal != 0 ? kmBiked / kmTotal : 0),
                        const SizedBox(height: 5),
                        ProgressBar(
                            icon: Icons.electric_car,
                            percentage:
                                kmTotal != 0 ? kmElectricCar / kmTotal : 0),
                        const SizedBox(height: 5),
                        ProgressBar(
                            icon: Icons.train,
                            percentage:
                                kmTotal != 0 ? kmPublicTransport / kmTotal : 0),
                        const SizedBox(height: 5),
                        ProgressBar(
                            icon: Icons.directions_bus,
                            percentage: kmTotal != 0 ? kmBus / kmTotal : 0),
                        const SizedBox(height: 5),
                        ProgressBar(
                            icon: Icons.motorcycle,
                            percentage:
                                kmTotal != 0 ? kmMotorcycle / kmTotal : 0),
                        const SizedBox(height: 5),
                        ProgressBar(
                            icon: Icons.directions_car,
                            percentage: kmTotal != 0 ? kmCar / kmTotal : 0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void share() {
    //Falta implementar funció de compartir estadístiques
  }

  void showMessage(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate(m)),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}

class ProgressBar extends StatelessWidget {
  final IconData icon;
  final double percentage;

  const ProgressBar({super.key, required this.icon, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 1, 167, 164),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${(percentage * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

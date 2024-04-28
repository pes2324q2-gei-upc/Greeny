import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Statistics/routes.dart';
import 'dart:convert';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  double co2Consumed = 0;
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
    final response = await httpGet('/api/statistics/');

    if (response.statusCode == 200) {
      List<dynamic> statsDataList = json.decode(response.body);

      if (statsDataList.isNotEmpty) {
        Map<String, dynamic> statsData = statsDataList[0];

        setState(() {
          //co2Consumed = statsData['kg_CO2_consumed'].toDouble();
          kmTotal = statsData['km_Totals'].toDouble();
          kmWalked = statsData['km_Walked'].toDouble();
          kmBiked = statsData['km_Biked'].toDouble();
          kmElectricCar = statsData['km_ElectricCar'].toDouble();
          kmPublicTransport = statsData['km_PublicTransport'].toDouble();
          kmBus = statsData['km_Bus'].toDouble();
          kmMotorcycle = statsData['km_Motorcycle'].toDouble();
          kmCar = statsData['km_Car'].toDouble();
        });
      }
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
          title: Text(translate('Statistics'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            onPressed: routes,
            icon: const Icon(Icons.history),
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
        )),
        body: CustomScrollView(
          shrinkWrap: false,
          scrollDirection: Axis.vertical,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: double
                          .infinity, // makes the button take up the full width of its parent
                      height: 60, // sets the height of the button
                      margin: const EdgeInsets.only(
                          top: 20), // moves the button a little bit up
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RoutesPage()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 1, 167, 164)),
                        ),
                        child: Text(translate('My Routes')),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                    Text('$co2Consumed kg',
                                        style: const TextStyle(
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold)),
                                    Text(translate('of CO2 consumed'),
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
                          ]),
                    ),
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(translate('PERCENTAGE OF USE'),
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void routes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoutesPage()),
    );
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

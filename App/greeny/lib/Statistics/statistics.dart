import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:greeny/Statistics/routes.dart';
import 'dart:convert';
import 'package:greeny/utils/utils.dart';
import '../utils/info_dialog.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key, required this.sharing});
  final bool sharing;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  double co2Consumed = 0;
  double carCO2Consumed = 0;
  double kmTotal = 0;
  double kmWalked = 0;
  double kmBiked = 0;
  double kmElectricCar = 0;
  double kmPublicTransport = 0;
  double kmBus = 0;
  double kmMotorcycle = 0;
  double kmCar = 0;

  String selectedOption = 'all';

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
          co2Consumed = statsData['kg_CO2_consumed'].toDouble();
          carCO2Consumed = statsData['kg_CO2_car_consumed'].toDouble();
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
      if (mounted) {
        showMessage(context, translate("Error loading statistics"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: widget.sharing
          ? null // Oculta la AppBar si sharing es true
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 220, 255, 255),
              title: Text(
                translate('Statistics'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showInformationDialog(context);
                  },
                  icon: const Icon(Icons.info_outline_rounded),
                  color: const Color.fromARGB(255, 1, 167, 164),
                ),
              ],
            ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            if (!widget.sharing) ...[
              _buildSelectionButtons(),
            ],
            if (selectedOption == 'all') ...[
              InfoBox(
                icon: Icons.route,
                title: translate('Distance traveled'),
                subtitle: '',
                value: kmTotal.toStringAsFixed(2),
                unit: 'km',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.cloud,
                      title: translate('CO2 consumed'),
                      subtitle: translate('If travelled by combustion car'),
                      value: carCO2Consumed.toStringAsFixed(2),
                      unit: 'kg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.nature_rounded,
                      title: translate('Unfelled trees'),
                      subtitle: '',
                      value: ((carCO2Consumed - co2Consumed) / 21.77)
                          .toStringAsFixed(2),
                      unit: translate('trees'),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.cloud,
                      title: translate('CO2 consumed'),
                      subtitle: '',
                      value: co2Consumed.toStringAsFixed(2),
                      unit: 'kg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.electric_bolt,
                      title: translate('Energy saved'),
                      subtitle: '',
                      value: ((carCO2Consumed - co2Consumed) / 0.280)
                          .toStringAsFixed(2),
                      unit: 'kWh',
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.eco_rounded,
                      title: translate('CO2 saved'),
                      subtitle: '',
                      value: (carCO2Consumed - co2Consumed).toStringAsFixed(2),
                      unit: 'kg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.family_restroom,
                      title: translate('Families supplied'),
                      subtitle: '',
                      value: (((carCO2Consumed - co2Consumed) / 0.280) / 4000)
                          .toStringAsFixed(2),
                      unit: translate('families'),
                    ),
                  ),
                ],
              ),
            ] else if (selectedOption == 'real') ...[
              InfoBox(
                icon: Icons.route,
                title: translate('Distance traveled'),
                subtitle: '',
                value: kmTotal.toStringAsFixed(2),
                unit: 'km',
              ),
              InfoBox(
                icon: Icons.cloud,
                title: translate('CO2 consumed'),
                subtitle: '',
                value: co2Consumed.toStringAsFixed(2),
                unit: 'kg',
              ),
            ] else if (selectedOption == 'estimated') ...[
              InfoBox(
                icon: Icons.cloud,
                title: translate('CO2 consumed'),
                subtitle: translate('If travelled by combustion car'),
                value: carCO2Consumed.toStringAsFixed(2),
                unit: 'kg',
              ),
              InfoBox(
                icon: Icons.eco_rounded,
                title: translate('CO2 saved'),
                subtitle: '',
                value: (carCO2Consumed - co2Consumed).toStringAsFixed(2),
                unit: 'kg',
              ),
              InfoBox(
                icon: Icons.nature_rounded,
                title: translate('Unfelled trees'),
                subtitle: '',
                value:
                    ((carCO2Consumed - co2Consumed) / 21.77).toStringAsFixed(2),
                unit: translate('trees'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.electric_bolt,
                      title: translate('Energy saved'),
                      subtitle: '',
                      value: ((carCO2Consumed - co2Consumed) / 0.280)
                          .toStringAsFixed(2),
                      unit: 'kWh',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: InfoBox(
                      icon: Icons.family_restroom,
                      title: translate('Families supplied'),
                      subtitle: '',
                      value: (((carCO2Consumed - co2Consumed) / 0.280) / 4000)
                          .toStringAsFixed(2),
                      unit: translate('families'),
                    ),
                  ),
                ],
              ),
            ],
            if (!widget.sharing) ...[
              const SizedBox(height: 20),
              _buildRoutesButton(),
              if ((selectedOption == 'all' || selectedOption == 'real')) ...[
                const SizedBox(height: 20),
                _buildProgressBar(Icons.directions_walk, kmWalked),
                _buildProgressBar(Icons.directions_bike, kmBiked),
                _buildProgressBar(Icons.electric_car, kmElectricCar),
                _buildProgressBar(Icons.train, kmPublicTransport),
                _buildProgressBar(Icons.directions_bus, kmBus),
                _buildProgressBar(Icons.motorcycle, kmMotorcycle),
                _buildProgressBar(Icons.directions_car, kmCar),
              ],
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildSelectionButton('all', translate('All')),
        const SizedBox(width: 8),
        _buildSelectionButton('real', translate('Real data')),
        const SizedBox(width: 8),
        _buildSelectionButton('estimated', translate('Estimated data')),
      ],
    );
  }

  Widget _buildSelectionButton(String value, String text) {
    return Flexible(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedOption = value;
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          backgroundColor: selectedOption == value
              ? Theme.of(context).colorScheme.inversePrimary
              : Colors.white,
          foregroundColor:
              selectedOption == value ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: selectedOption == value
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Colors.black,
            ),
          ),
        ),
        child: AutoSizeText(
          text,
          style: const TextStyle(fontSize: 10),
          minFontSize: 1,
          maxLines: 1,
        ),
      ),
    );
  }

  // Widget for the "My Routes" button
  Widget _buildRoutesButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 160.0,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoutesPage()),
            );
          },
          child: Text(translate('My Routes')),
        ),
      ),
    );
  }

  // Widget to display a progress bar
  Widget _buildProgressBar(IconData icon, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: ProgressBar(
        icon: icon,
        percentage: kmTotal != 0 ? value / kmTotal : 0,
      ),
    );
  }

  // Method to navigate to routes page
  void routes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoutesPage()),
    );
  }
}

// Custom progress bar widget
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
          Text(
            '${(percentage * 100).toStringAsFixed(2)}%',
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String unit;

  const InfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  minFontSize: 1,
                ),
                if (subtitle.isNotEmpty)
                  AutoSizeText(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: 1,
                  ),
                const SizedBox(height: 8),
                AutoSizeText(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

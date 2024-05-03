import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Statistics/routes.dart';
import 'dart:convert';
import 'package:greeny/utils/utils.dart';
import '../utils/info_dialog.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

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
      appBar: AppBar(
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
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            _buildInfoCard(translate('travelled'), kmTotal, 'km', Icons.route),
            _buildInfoCard(
                translate('of CO2 consumed'), co2Consumed, 'kg', Icons.cloud),
            _buildInfoCard((translate('co2_consumed_combustion_car')),
                carCO2Consumed, 'kg', Icons.directions_car),
            const SizedBox(height: 20),
            _buildRoutesButton(),
            const SizedBox(height: 40),
            _buildProgressBar(Icons.directions_walk, kmWalked),
            _buildProgressBar(Icons.directions_bike, kmBiked),
            _buildProgressBar(Icons.electric_car, kmElectricCar),
            _buildProgressBar(Icons.train, kmPublicTransport),
            _buildProgressBar(Icons.directions_bus, kmBus),
            _buildProgressBar(Icons.motorcycle, kmMotorcycle),
            _buildProgressBar(Icons.directions_car, kmCar),
          ],
        ),
      ),
    );
  }

  // Widget to display statistical information
  Widget _buildInfoCard(
      String label, double value, String unit, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              '${value.toStringAsFixed(2)} $unit',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          translate(label),
          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
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

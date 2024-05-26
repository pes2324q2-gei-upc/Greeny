import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:greeny/Statistics/routes.dart';
import 'dart:convert';
import 'package:greeny/utils/utils.dart';
import '../utils/info_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key, required this.sharing});
  final bool sharing;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class Transport {
  final String type;
  final IconData icon;
  final double km;
  final double co2;

  Transport(this.type, this.icon, this.km, this.co2);
}

class _StatisticsPageState extends State<StatisticsPage> {
  double co2Consumed = 0;
  double carCO2Consumed = 0;
  double kmTotal = 0;

  List<Transport> transports = [];

  String selectedOption = 'all';

  @override
  void initState() {
    super.initState();
    getStats();
  }

  Future<void> getStats() async {
    final response = await httpGet('/api/statistics/');

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('statistics') &&
          responseData['statistics'].isNotEmpty) {
        Map<String, dynamic> statsData = responseData['statistics'][0];
        Map<String, dynamic> co2Data = responseData['first_co2_consumed'];

        setState(() {
          co2Consumed = statsData['kg_CO2_consumed'].toDouble();
          carCO2Consumed = statsData['kg_CO2_car_consumed'].toDouble();
          kmTotal = statsData['km_Totals'].toDouble();

          transports = [
            Transport(
                translate('Walking'),
                Icons.directions_walk,
                statsData['km_Walked'].toDouble(),
                co2Data['kg_CO2_walking_biking_consumed'].toDouble()),
            Transport(
                translate('Bike'),
                Icons.directions_bike,
                statsData['km_Biked'].toDouble(),
                co2Data['kg_CO2_walking_biking_consumed'].toDouble()),
            Transport(
                translate('Electric Car'),
                Icons.electric_car,
                statsData['km_ElectricCar'].toDouble(),
                co2Data['kg_CO2_electric_car_consumed'].toDouble()),
            Transport(
                translate('Public Transport'),
                Icons.train,
                statsData['km_PublicTransport'].toDouble(),
                (co2Data['kg_CO2_train_consumed'].toDouble() +
                        co2Data['kg_CO2_metro_consumed'].toDouble() +
                        co2Data['kg_CO2_tram_consumed'].toDouble() +
                        co2Data['kg_CO2_fgc_consumed'].toDouble()) /
                    4),
            Transport(
                translate('Bus'),
                Icons.directions_bus,
                statsData['km_Bus'].toDouble(),
                co2Data['kg_CO2_bus_consumed'].toDouble()),
            Transport(
                translate('Motorcycle'),
                Icons.motorcycle,
                statsData['km_Motorcycle'].toDouble(),
                co2Data['kg_CO2_motorcycle_consumed'].toDouble()),
            Transport(
                translate('Car'),
                Icons.directions_car,
                statsData['km_Car'].toDouble(),
                co2Data['kg_CO2_car_gasoline_consumed'].toDouble()),
          ];
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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: ListView(
          children: [
            if (!widget.sharing) ...[
              _buildSelectionButtons(),
            ],
            const SizedBox(height: 20),
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
                      title: translate('CO2 estimated'),
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
                title: translate('CO2 estimated'),
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
                const SizedBox(height: 10),
                TransportationPieChart(transports),
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
    return ElevatedButton(
        onPressed: () {
          setState(() {
            selectedOption = value;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedOption != value
              ? null
              : const Color.fromARGB(255, 1, 167, 164),
        ),
        child: Text(
          text,
          style:
              TextStyle(color: (selectedOption != value ? null : Colors.white)),
        ));
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

  // Method to navigate to routes page
  void routes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoutesPage()),
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
                if (title.contains('CO2')) ...[
                  AutoSizeText.rich(
                    TextSpan(children: [
                      const TextSpan(text: 'CO'),
                      const TextSpan(
                        text: '2',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: title.split('CO2')[1]),
                    ]),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: 1,
                  ),
                ] else ...[
                  AutoSizeText(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: 1,
                  ),
                ],
                if (subtitle.isNotEmpty)
                  AutoSizeText(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: 1,
                  ),
                const SizedBox(height: 6),
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

class TransportationPieChart extends StatelessWidget {
  final List<Transport> transports;
  final Map<String, Color> colorList = {
    translate('Walking'): const Color(0xFF4A4BA2),
    translate('Bike'): const Color(0xFF4C87B9),
    translate('Electric Car'): const Color(0xFFC26C85),
    translate('Public Transport'): const Color(0xFFF67180),
    translate('Bus'): const Color(0xFFF8B195),
    translate('Motorcycle'): const Color(0xFF75B49A),
    translate('Car'): const Color(0xFF00A7B4),
  };

  TransportationPieChart(this.transports, {super.key});

  @override
  Widget build(BuildContext context) {
    var data = transports;
    return Column(
      children: [
        SfCircularChart(
          legend: const Legend(isVisible: false),
          series: <PieSeries<Transport, String>>[
            PieSeries<Transport, String>(
              dataSource: transports,
              xValueMapper: (Transport data, _) => data.type,
              yValueMapper: (Transport data, _) => data.km,
              dataLabelMapper: (Transport data, _) =>
                  '${(data.km).toStringAsFixed(2)}km',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              pointColorMapper: (Transport data, _) => colorList[data.type],
            ),
          ],
        ),
        ...data.map((e) => ListTile(
            leading: Icon(Icons.circle,
                color: colorList[e.type]), // replace with your color
            title: Text(e.type),
            onTap: () => showProgressInfoDialog(context, e)))
      ],
    );
  }

  void showProgressInfoDialog(BuildContext context, Transport t) {
    Transport carTransport =
        transports.firstWhere((t) => t.type == translate('Car'));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildDialogTitle(t),
          content: _buildDialogContent(t, carTransport),
          actions: _buildDialogActions(context),
        );
      },
    );
  }

  Widget _buildDialogTitle(Transport t) {
    return Row(
      children: [
        Icon(t.icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            translate('Detailed info'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogContent(Transport t, Transport carTransport) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDistanceTraveled(t),
        const SizedBox(height: 10),
        _buildCO2Consumed(t),
        const SizedBox(height: 10),
        _buildCO2Saved(t, carTransport),
      ],
    );
  }

  Widget _buildDistanceTraveled(Transport t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${translate('Distance traveled')}: ',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          '${t.km.toStringAsFixed(2)} km',
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildCO2Consumed(Transport t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: Colors.black),
            children: [
              const TextSpan(text: 'CO'),
              const WidgetSpan(
                child: Text(
                  '2',
                  style: TextStyle(fontSize: 8),
                ),
              ),
              TextSpan(
                text: ' ${translate('CO2 consumed').split('CO2')[1]}:',
              ),
            ],
          ),
        ),
        Text(
          '${(t.km * t.co2).toStringAsFixed(2)} kg',
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildCO2Saved(Transport t, Transport carTransport) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: Colors.black),
            children: [
              const TextSpan(text: 'CO'),
              const WidgetSpan(
                child: Text(
                  '2',
                  style: TextStyle(fontSize: 8),
                ),
              ),
              TextSpan(
                text: ' ${translate('CO2 saved').split('CO2')[1]}:',
              ),
            ],
          ),
        ),
        Text(
          '${(t.km * carTransport.co2 - t.km * t.co2).toStringAsFixed(2)} kg',
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(translate('Exit')),
      ),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/main_page.dart';
import 'dart:convert';
import '../utils/info_dialog.dart';

class FormFinalPage extends StatefulWidget {
  final double totalDistance;
  final DateTime startedAt;
  const FormFinalPage({
    super.key,
    required this.totalDistance,
    required this.startedAt,
  });

  @override
  State<FormFinalPage> createState() => _FormFinalPageState();
}

class _FormFinalPageState extends State<FormFinalPage> {
  final List<bool> isSelected = List.generate(7, (_) => false);
  final List<String> transportModes = [
    'Walking',
    'Bike',
    'Bus',
    'Train, Metro, Tram, FGC',
    'Motorcycle',
    'Electric Car',
    'Car'
  ];
  final Map<String, double> transportPercentages = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color.fromARGB(255, 1, 167, 164),
            ),
            onPressed: () => showInformationDialog(context),
          ),
        ],
      ),
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 40, 10, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        translate("Which transports have \nyou used?"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(isSelected.length, (index) {
                              return GestureDetector(
                                onTap: () => _toggleTransport(index),
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: isSelected[index]
                                        ? const Color.fromARGB(131, 1, 164, 167)
                                        : null,
                                    borderRadius: BorderRadius.circular(30),
                                    border:
                                        Border.all(color: Colors.transparent),
                                  ),
                                  child: Icon(
                                    getTransportIcon(index),
                                    size: 40,
                                  ),
                                ),
                              );
                            }),
                          )),
                      const SizedBox(height: 25.0),
                      ..._buildSliders(),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _sendData,
                        child: Text(translate("Submit")),
                      ),
                      TextButton(
                        onPressed: _showExitDialog,
                        child: Text(translate("Don't answer")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTransport(int index) {
    setState(() {
      isSelected[index] = !isSelected[index];
      if (isSelected[index]) {
        if (index == 3) {
          // 'Train, Metro, Tram, FGC' option selected
          transportPercentages['Train'] = 0.0;
          transportPercentages['Metro'] = 0.0;
          transportPercentages['Tram'] = 0.0;
          transportPercentages['FGC'] = 0.0;
        } else {
          transportPercentages[transportModes[index]] = 0.0;
        }
      } else {
        if (index == 3) {
          // 'Train, Metro, Tram, FGC' option deselected
          transportPercentages.remove('Train');
          transportPercentages.remove('Metro');
          transportPercentages.remove('Tram');
          transportPercentages.remove('FGC');
        } else {
          transportPercentages.remove(transportModes[index]);
        }
      }
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate("Are you sure?")),
        content: Text(
            translate(
              "You chose not to answer. You will not get extra points to improve "
              "your city and your transports statics won't be updated.",
            ),
            textAlign: TextAlign.justify),
        actions: <Widget>[
          TextButton(
            onPressed: _sendDataToServer,
            child: Text(translate("Ok")),
          ),
          TextButton(
            child: Text(translate("Cancel")),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showSliderSumErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Error')),
          content: Text(
            translate('The sum of the slider values must be 100%. '
                'You also have the possibility of not answering the form.'),
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate('Ok')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendData() async {
    int sum = transportPercentages.values
        .fold(0, (prev, curr) => prev + curr.round());

    if (transportPercentages.isEmpty) {
      _showExitDialog();
    } else if (sum != 100) {
      _showSliderSumErrorDialog();
    } else {
      _sendDataToServer();
    }
  }

  void _sendDataToServer() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(translate("Sending data...")),
              ),
            ],
          ),
        );
      },
    );

    await httpPost(
        'api/send-form-transports',
        jsonEncode({
          'totalDistance': widget.totalDistance,
          'startedAt': widget.startedAt.toIso8601String(),
          'transportPercentages': transportPercentages,
        }),
        'application/json');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _updateSliderValue(String mode, double value) {
    setState(() {
      double roundedValue = (value / 5).round() * 5.0;
      transportPercentages[mode] = roundedValue;
      double totalPercentage =
          transportPercentages.values.fold(0.0, (prev, curr) => prev + curr);
      if (totalPercentage > 100.0) {
        double excess = totalPercentage - 100.0;
        transportPercentages[mode] = roundedValue - excess;
      }
    });
  }

  List<Widget> _buildSliders() {
    return [
      if (transportPercentages.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            translate(
                'Indicate the percentage usage of each mode of transport'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ...transportPercentages.keys.map((mode) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translate(mode),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${transportPercentages[mode]!.round()}%'),
                ],
              ),
            ),
            Slider(
              value: transportPercentages[mode]!,
              min: 0,
              max: 100,
              onChanged: (double value) {
                _updateSliderValue(mode, value);
              },
            ),
          ],
        );
      }),
    ];
  }
}

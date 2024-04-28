import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/main_page.dart';
import 'dart:convert';

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

  final List<double> sliderValues = List.generate(10, (_) => 0.0);
  List<int> selectedIndices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _showInformationDialog,
                              child: const Icon(Icons.info_outline_rounded,
                                  size: 35),
                            ),
                          ],
                        ),
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
                              children:
                                  List.generate(isSelected.length, (index) {
                                return GestureDetector(
                                  onTap: () => _toggleTransport(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: isSelected[index]
                                          ? const Color.fromARGB(
                                              131, 1, 164, 167)
                                          : null,
                                      borderRadius: BorderRadius.circular(30),
                                      border:
                                          Border.all(color: Colors.transparent),
                                    ),
                                    child: Icon(
                                      _getTransportIcon(index),
                                      size: 40,
                                    ),
                                  ),
                                );
                              }),
                            )),
                        const SizedBox(height: 40),
                        ..._buildTransportSliders(),
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
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTransportIcon(int index) {
    switch (index) {
      case 0:
        return Icons.directions_walk;
      case 1:
        return Icons.directions_bike;
      case 2:
        return Icons.directions_bus;
      case 3:
        return Icons.train;
      case 4:
        return Icons.motorcycle;
      case 5:
        return Icons.electric_car;
      default:
        return Icons.directions_car;
    }
  }

  void _toggleTransport(int index) {
    setState(() {
      isSelected[index] = !isSelected[index];
      if (!isSelected[index]) {
        sliderValues.removeAt(index);
        sliderValues.add(0.0);
      }
    });
  }

  void _showInformationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                  child: Text(translate("Information"),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              for (int i = 0; i < transportModes.length; i++)
                _buildRow(translate(transportModes[i]), _getTransportIcon(i)),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(translate("Exit"))),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 5),
          Container(height: 2, color: const Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              const SizedBox(width: 16),
              Text(name),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Icon(icon),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String mode, int valueIndex) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Slider(
            value: sliderValues[valueIndex],
            min: 0,
            max: 100,
            onChanged: (double value) {
              setState(() {
                sliderValues[valueIndex] = (value / 5).round() * 5.0;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mode,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${sliderValues[valueIndex].toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTransportSliders() {
    List<Widget> sliders = [];
    int valueIndex = 0;
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        if (transportModes[i] == 'Train, Metro, Tram, FGC') {
          // Special case: add four sliders
          for (var mode in ['Train', 'Metro', 'Tram', 'FGC']) {
            sliders.add(_buildSlider(mode, valueIndex));
            valueIndex++;
          }
        } else {
          // Normal case: add one slider
          sliders.add(_buildSlider(transportModes[i], valueIndex));
          valueIndex++;
        }
      }
    }
    return sliders;
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate("Are you sure?")),
        content: Text(
            translate(
                "You chose not to answer. You will not get extra points to improve your city and your transports statics won't be updated."),
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
          'selectedTransports': _getSelectedTransports(),
          'totalDistance': widget.totalDistance,
          'startedAt': widget.startedAt.toIso8601String(),
        }),
        'application/json');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _sendData() async {
    List<String> selectedTransports = _getSelectedTransports();
    if (selectedTransports.isEmpty) {
      _showExitDialog();
    } else {
      _sendDataToServer();
    }
  }

  List<String> _getSelectedTransports() {
    List<String> selectedTransports = [];
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        selectedTransports.add(transportModes[i]);
      }
    }
    return selectedTransports;
  }
}

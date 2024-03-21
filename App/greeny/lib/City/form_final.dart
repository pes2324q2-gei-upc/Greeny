import 'package:flutter/material.dart';
import 'package:greeny/main_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FormFinalPage extends StatefulWidget {
  final double totalDistance;

  const FormFinalPage({super.key, required this.totalDistance});

  @override
  State<FormFinalPage> createState() => _FormFinalPageState();
}

class _FormFinalPageState extends State<FormFinalPage> {
  final List<bool> isSelected = List.generate(7, (_) => false);
  final List<String> transportModes = [
    'Walking',
    'By bike',
    'By bus',
    'By publicTransport',
    'By motorcycle',
    'By electricCar',
    'By car'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 40, 5, 0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _showInformationDialog,
                        child: const Icon(Icons.info_outline_rounded, size: 35),
                      ),
                    ],
                  ),
                  const Text(
                    "Which transports have \nyou used?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(isSelected.length, (index) {
                      return GestureDetector(
                        onTap: () => _toggleTransport(index),
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: isSelected[index]
                                ? const Color.fromARGB(131, 1, 164, 167)
                                : null,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Icon(
                            _getTransportIcon(index),
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ),
            const SizedBox(height: 450),
            ElevatedButton(
              onPressed: _sendData,
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: _showExitDialog,
              child: const Text("Don't answer"),
            ),
          ],
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
              const Center(
                  child: Text('Information',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              for (int i = 0; i < transportModes.length; i++)
                _buildRow(transportModes[i], _getTransportIcon(i)),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Exit')),
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

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
            'You chose not to answer. You will not get extra points to improve your city and your transports statics won\'t be updated.',
            textAlign: TextAlign.justify),
        actions: <Widget>[
          TextButton(
            onPressed: _sendDataToServer,
            child: const Text('OK'),
          ),
          TextButton(
            child: const Text('Cancel'),
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
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Sending data...'),
              ),
            ],
          ),
        );
      },
    );

    var url = Uri.http(dotenv.env['BACKEND_URL']!, 'api/send-form-transports');
    await http.post(url,
        body: jsonEncode({
          'selectedTransports': _getSelectedTransports(),
          'totalDistance': widget.totalDistance,
        }));

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

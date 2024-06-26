import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

void showInformationDialog(BuildContext context) {
  final List<String> transportModes = [
    'Walking',
    'Bike',
    'Bus',
    'Train, Metro, Tram, FGC',
    'Motorcycle',
    'Electric Car',
    'Car'
  ];
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const SizedBox(height: 20),
            Center(
                child: Text(translate("Information"),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            for (int i = 0; i < transportModes.length; i++)
              _buildRow(translate(transportModes[i]), _getTransportIcon(i)),
            _buildRowNoIcon(translate("co2_estimated")),
            _buildRowNoIcon(translate("unfelled_trees")),
            _buildRowNoIcon(translate("families_supplied")),
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
            Expanded(
              child: Text(name),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Icon(icon),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildRowNoIcon(String name) {
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
            Expanded(
              child: AutoSizeText(
                name,
                maxLines: 3,
                minFontSize: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
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

IconData getTransportIcon(int index) {
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

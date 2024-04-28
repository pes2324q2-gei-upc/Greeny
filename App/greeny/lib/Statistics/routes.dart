import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:intl/intl.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  List<Map<String, dynamic>> routes = [];

  @override
  void initState() {
    super.initState();
    getRoutes();
  }

  Future<void> getRoutes() async {
    final response = await httpGet('/api/routes');
    if (response.statusCode == 200) {
      List<dynamic> routesDataList = json.decode(response.body);

      if (routesDataList.isNotEmpty) {
        setState(() {
          // Update the routes state variable
          routes = routesDataList.cast<Map<String, dynamic>>();
        });
      }
    } else {
      showMessage("Error loading routes");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(translate('My Routes'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: buildListView(),
      ),
    );
  }

  ListView buildListView() {
    var reversedRoutes = routes.reversed.toList();

    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: reversedRoutes.length,
      itemBuilder: (context, index) => buildListItem(reversedRoutes, index),
    );
  }

  Widget buildListItem(List<Map<String, dynamic>> reversedRoutes, int index) {
    Map<String, dynamic> route = reversedRoutes[index];

    String startedAtString = route['started_at'];
    DateTime startedAt = DateTime.parse(startedAtString);
    String formattedDateTime =
        DateFormat('dd-MM-yyyy, kk:mm').format(startedAt);

    String formattedTotalTime = route['total_time'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: Card(
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDateTime,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(formattedTotalTime)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text(
                        'Total distance: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${(route['distance'] as double).toStringAsFixed(3)} km'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text(
                        'Consumed CO2: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${(route['consumed_co2'] as double).toStringAsFixed(3)} kg'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text(
                        'Car consumed CO2: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${(route['car_consumed_co2'] as double).toStringAsFixed(3)} kg'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: route['transports'].map<Widget>((transport) {
                    Widget icon;
                    switch (transport) {
                      case 'Walking':
                        icon = const Icon(Icons.directions_walk, size: 24);
                        break;
                      case 'Bike':
                        icon = const Icon(Icons.directions_bike, size: 24);
                        break;
                      case 'Bus':
                        icon = const Icon(Icons.directions_bus, size: 24);
                        break;
                      case 'Train, Metro, Tram, FGC':
                        icon = const Icon(Icons.train, size: 24);
                        break;
                      case 'Motorcycle':
                        icon = const Icon(Icons.motorcycle, size: 24);
                        break;
                      case 'Electric Car':
                        icon = const Icon(Icons.electric_car, size: 24);
                        break;
                      case 'Car':
                        icon = const Icon(Icons.directions_car, size: 24);
                        break;
                      default:
                        icon = const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: icon,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showRouteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Route ${index + 1}'),
          content: Text('You clicked on Route ${index + 1}'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

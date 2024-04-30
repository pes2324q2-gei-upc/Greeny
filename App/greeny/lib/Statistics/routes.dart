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

  final Map<String, IconData> transportIcons = {
    'Walking': Icons.directions_walk,
    'Bike': Icons.directions_bike,
    'Bus': Icons.directions_bus,
    'Public Transport': Icons.train,
    'Motorcycle': Icons.motorcycle,
    'Electric Car': Icons.electric_car,
    'Car': Icons.directions_car,
  };

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
          routes = routesDataList.cast<Map<String, dynamic>>();
        });
      }
    } else {
      showMessage(translate("Error loading routes"));
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
    DateTime startedAt = DateTime.parse(startedAtString).toLocal();
    String formattedDateTime =
        DateFormat('dd-MM-yyyy, kk:mm').format(startedAt);
    String totalTime = route['total_time'];
    //print(formattedDateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: Card(
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Column(
            children: [
              buildHeader(formattedDateTime, totalTime),
              buildInfoRow(
                  translate('Total distance: '), route['distance'], 'km'),
              buildInfoRow(
                  translate('Consumed CO2: '), route['consumed_co2'], 'kg'),
              buildInfoRow(translate('Car consumed CO2: '),
                  route['car_consumed_co2'], 'kg'),
              const SizedBox(height: 17),
              buildTransportIcons(route['transports']),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(String dateTime, String totalTime) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dateTime,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(totalTime)
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${value.toStringAsFixed(3)} $unit'),
          ],
        ),
      ),
    );
  }

  IconData getIconForTransportMode(String mode) {
    if (['Train', 'Metro', 'Tram', 'FGC'].contains(mode)) {
      return transportIcons['Public Transport'] ?? Icons.error;
    }
    return transportIcons[mode] ?? Icons.error;
  }

  Widget buildTransportIcons(List<dynamic> transports) {
    Set<String> uniqueTransports = transports.map<String>((transport) {
      String transportMode = transport.toString();
      if (['Train', 'Metro', 'Tram', 'FGC'].contains(transportMode)) {
        return 'Public Transport';
      }
      return transportMode;
    }).toSet();

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: uniqueTransports.map<Widget>((transport) {
          IconData iconData = getIconForTransportMode(transport);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(iconData, size: 24),
          );
        }).toList(),
      ),
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

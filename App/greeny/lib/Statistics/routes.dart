import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  List<Map<String, dynamic>> routes = []; // Declare routes as a state variable

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
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: routes.length,
      itemBuilder: (context, index) => buildListItem(index),
    );
  }

  Widget buildListItem(int index) {
    Map<String, dynamic> route = routes[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => showRouteDialog(context, index),
        child: SizedBox(
          height: 150,
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
                      Text('Route ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(route['distance'].toString()),
                )
              ],
            ),
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

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/City/explore_city.dart';
import 'package:greeny/API/requests.dart';

import 'dart:convert';
//import 'package:greeny/utils/utils.dart';

class HistoryPage extends StatefulWidget {
  final int level;

  HistoryPage({Key? key, required this.level}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final int level_aux = 4;

  List<dynamic> data = [];
  int numNeighborhoods = 0;
  bool isLoading = true;

  @override
  void initState() {
    //getInfo();
    super.initState();
    getInfo().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            SizedBox(height: 30), // Adjust the height as needed
            Expanded(
              child: SingleChildScrollView(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  //mainAxisSpacing: -10,
                  children: List.generate(numNeighborhoods, (index) {
                    return Column(
                      children: <Widget>[
                        Container(
                          height: 125, // Set the height and width to the same value
                          width: 125, // Set the height and width to the same value
                          child: ElevatedButton(
                            onPressed: () => exploreCity(index),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              padding: EdgeInsets.all(20),
                            ),
                            child: Image.asset(data[index]['completed'] ? 'assets/neighborhoods/City${1}PNG.png' : 'assets/neighborhoods/City${1}PNG_BW.png'),
                          ),
                        ),
                        Text('${data[index]['neighborhood']['name']}'),
                      ],
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      );
    }
  }

  exploreCity(index) {
    if (data[index]['completed']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          //builder: (context) => ExploreCity(index: index),
          builder: (context) => ExploreCity(name: data[index]['neighborhood']['name'], path: data[index]['neighborhood']['path']),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Title'), // Reemplaza 'Title' con el título de tu diálogo
            content: Text('PRUEBA'), // Reemplaza 'PRUEBA' con el contenido de tu diálogo
            actions: <Widget>[
              TextButton(
                child: Text('Close'), // Reemplaza 'Close' con el texto de tu botón
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getInfo() async {
    var responseNeighborhoods = await httpGet('api/neighborhoods/');
    if (responseNeighborhoods.statusCode == 200) {
      String body = utf8.decode(responseNeighborhoods.bodyBytes);
      data = jsonDecode(body);
    }
    numNeighborhoods = data.length;
    print(numNeighborhoods);
    print(data[1]['completed']);
  }
}
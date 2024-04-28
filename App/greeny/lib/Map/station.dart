import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:greeny/Map/add_review.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key, required this.stationId, required this.type});

  final int stationId;
  final String type;

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  int get stationId => widget.stationId;
  String get type => widget.type;

  bool isLoading = true;
  bool isFavorite = false;

  Map<String, dynamic> station = {};

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 220, 255, 255),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(station['name']),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                rating(),
                specificInfo(),
                reviews(),
              ],
            ),
          ));
    }
  }

  rating() {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(children: [
              const Icon(Icons.star, color: Colors.yellow, size: 30),
              const SizedBox(width: 5),
              Text(
                station['rating'].toString(),
                style: const TextStyle(fontSize: 20),
              ),
            ]),
            IconButton(
              onPressed: () async {
                var responseFav = await httpPost('api/stations/$stationId',
                    jsonEncode({}), 'application/json');
                if (responseFav.statusCode == 200) {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                }
              },
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            )
          ],
        ));
  }

  specificInfo() {
    switch (type) {
      case 'TMB':
        {
          return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${translate('Stops')}:',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                          onPressed: () =>
                              mapsGo(station['latitude'], station['longitude']),
                          child: Text(translate('Go')))
                    ],
                  ),
                  tmbStops(),
                ],
              ));
        }
      case 'BUS':
        {
          return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${translate('Lines')}:',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                            onPressed: () => mapsGo(
                                station['latitude'], station['longitude']),
                            child: Text(translate('Go')))
                      ],
                    ),
                    busLines(),
                  ]));
        }
      case 'BICING':
        {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${translate('Capacity')}:',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                        onPressed: () =>
                            mapsGo(station['latitude'], station['longitude']),
                        child: Text(translate('Go')))
                  ],
                ),
                RawMaterialButton(
                    constraints: BoxConstraints.tight(const Size(80, 40)),
                    onPressed: () => {},
                    shape: const BeveledRectangleBorder(),
                    fillColor: const Color.fromARGB(255, 207, 32, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.directions_bike, color: Colors.white),
                        Text(' ${station['capacitat']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ))
              ],
            ),
          );
        }
      case 'CAR':
        {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${translate('Information')}:',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                        onPressed: () =>
                            mapsGo(station['latitude'], station['longitude']),
                        child: Text(translate('Go')))
                  ],
                ),
                Text('${translate('Access')}: ${station['acces']}'),
                Text('${translate('Power')}: ${station['power']} kW'),
                Text(
                    '${translate('Charging velocity')}: ${station['charging_velocity']}'),
                Text(
                    '${translate('Current type')}: ${station['current_type']}'),
                Text(
                    '${translate('Connector type')}: ${station['connexion_type']}'),
              ],
            ),
          );
        }
    }
  }

  reviews() {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${translate('Reviews')}:',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(
                    onPressed: addReview, child: Text(translate('Add review')))
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              child: Stack(
                children: [
                  review(),
                  review(),
                  review(),
                ],
              ),
            )
          ],
        ));
  }

  review() {
    return Card(
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sergi', style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.star, color: Colors.yellow)
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: const Text(
                'The Metro Station impresses with its modern design and vibrant murals, seamlessly blending form and function. Clear signage facilitates easy navigation, and the energetic platform buzzes with arriving and departing trains. Well-maintained facilities, including clean restrooms and snack kiosks, add to the overall commuter-friendly experience, making it a beacon of urban efficiency.'),
          )
        ],
      ),
    );
  }

  addReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddReviewPage(
              stationId: stationId, type: type, stationName: station['name'])),
    );
  }

  tmbStops() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (var stop in station['stops']) tmbLines(stop)]),
    );
  }

  tmbLines(stop) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stop['lines']
              .map<Widget>((line) => RawMaterialButton(
                  constraints: BoxConstraints.tight(const Size(40, 40)),
                  onPressed: () => onTapTmb(line),
                  shape: const RoundedRectangleBorder(),
                  fillColor: getColorTmb(line),
                  child: Text(line.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))))
              .toList(),
        ));
  }

  mapsGo(latitude, longitude) async {
    Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      throw 'Could not launch $googleMapsUri';
    }
  }

  busLines() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: station['lines']
              .map<Widget>((line) => RawMaterialButton(
                  constraints: BoxConstraints.tight(const Size(40, 40)),
                  onPressed: () => onTapBus(line),
                  shape: const CircleBorder(),
                  fillColor: getColorBus(line),
                  child: Text(line.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))))
              .toList(),
        ));
  }

  Color? getColorTmb(line) {
    switch (line[0]) {
      case 'T':
        return const Color.fromARGB(255, 61, 139, 121);
    }
    switch (line) {
      case 'L1':
        return const Color.fromARGB(255, 205, 61, 62);
      case 'L2':
        return const Color.fromARGB(255, 142, 66, 136);
      case 'L3':
        return const Color.fromARGB(255, 91, 166, 76);
      case 'L4':
        return const Color.fromARGB(255, 242, 192, 66);
      case 'L5':
        return const Color.fromARGB(255, 51, 117, 183);
      case 'L9':
        return const Color.fromARGB(255, 234, 146, 53);
    }
    return null;
  }

  Color? getColorBus(line) {
    switch (line[0]) {
      case 'V':
        return const Color.fromARGB(255, 107, 149, 67);
      case 'H':
        return const Color.fromARGB(255, 61, 65, 139);
      case 'D':
        return const Color.fromARGB(255, 144, 0, 206);
      case 'L' || 'E' || 'B' || 'M' || 'J' || 'P':
        return const Color.fromARGB(255, 241, 217, 0);
      case 'N':
        return const Color.fromARGB(255, 0, 95, 172);
      case 'X':
        return const Color.fromARGB(255, 148, 148, 148);
      case 'A':
        return const Color.fromARGB(255, 39, 183, 255);

      default:
        return const Color.fromARGB(255, 179, 0, 0);
    }
  }

  onTapBus(line) async {
    Uri tmbUri = Uri.parse(
        'https://www.tmb.cat/ca/barcelona/autobusos/-/lineabus/$line');
    if (await canLaunchUrl(tmbUri)) {
      await launchUrl(tmbUri);
    } else {
      throw 'Could not launch $tmbUri';
    }
  }

  onTapTmb(line) async {
    switch (line[0]) {
      case 'T':
        {
          Uri tmbUri = Uri.parse('https://www.tram.cat/ca/linies-i-horaris');
          if (await canLaunchUrl(tmbUri)) {
            await launchUrl(tmbUri);
          } else {
            throw 'Could not launch $tmbUri';
          }
        }
      default:
        {
          Uri tmbUri = Uri.parse(
              'https://www.tmb.cat/ca/barcelona/metro/-/lineametro/$line');
          if (await canLaunchUrl(tmbUri)) {
            await launchUrl(tmbUri);
          } else {
            throw 'Could not launch $tmbUri';
          }
        }
    }
  }

  Future<void> getInfo() async {
    var responseStation = await httpGet('api/stations/$stationId');
    if (responseStation.statusCode == 200) {
      String body = utf8.decode(responseStation.bodyBytes);
      station = jsonDecode(body);
      var responseReviews = await httpGet('api/stations/$stationId/reviews/');
      if (responseStation.statusCode == 200) {
        String body = utf8.decode(responseReviews.bodyBytes);
        //igualar la variable de reviews a lo que devuelve el body
        setState(() {
          isLoading = false;
        });
      }
      var responseFavs = await httpGet('api/user/');
      if (responseFavs.statusCode == 200) {
        List jsonList = jsonDecode(responseFavs.body);
        if (jsonList.isNotEmpty) {
          for (var json in jsonList) {
            var favorites = json['favorite_stations'];
            for (var favorite in favorites) {
              var station = favorite['station'];
              if (station['id'] == stationId) {
                setState(() {
                  isFavorite = true;
                });
                return;
              }
            }
          }
        }
        return;
      }
    }
    showMessage('Error loading station');
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

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key, required this.station, required this.type});

  final dynamic station;
  final String type;

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  dynamic get station => widget.station;
  String get type => widget.type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(station.name),
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
                station.rating.toString(),
                style: const TextStyle(fontSize: 20),
              ),
            ]),
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
                              mapsGo(station.latitude, station.longitude),
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
                            onPressed: () =>
                                mapsGo(station.latitude, station.longitude),
                            child: Text(translate('Go')))
                      ],
                    ),
                    Row(
                      children: station.lines
                          .map<Widget>((line) => (Text(line + ' ',
                              style: const TextStyle(fontSize: 15))))
                          .toList(),
                    )
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
                    Text('${translate('Information')}:',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                        onPressed: () =>
                            mapsGo(station.latitude, station.longitude),
                        child: Text(translate('Go')))
                  ],
                ),
                Text('${translate('Capacity')}: ${station.capacitat} ${translate('bikes')}',
                    style: const TextStyle(fontSize: 15)),
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
                            mapsGo(station.latitude, station.longitude),
                        child: Text(translate('Go')))
                  ],
                ),
                Text('${translate('Access')}: ${station.acces}'),
                Text('${translate('Power')}: ${station.power} kW'),
                Text('${translate('Charging velocity')}: ${station.charging_velocity}'),
                Text('${translate('Current type')}: ${station.current_type}'),
                Text('${translate('Connector type')}: ${station.connexion_type}'),
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
    print('Add review');
  }

  tmbStops() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(children: [for (var stop in station.stops) tmbLines(stop)]),
    );
  }

  tmbLines(stop) {
    return Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: stop.lines
              .map<Widget>((line) => Container(
                    padding: const EdgeInsets.only(right: 5),
                    child: Image(
                      image: AssetImage('assets/transports/lines/$line.png'),
                      height: 25,
                      width: 25,
                    ),
                  ))
              .toList(),
        ));
  }

  mapsGo(latitude, longitude) {
    print('Go to maps');
    print('Latitude: $latitude');
    print('Longitude: $longitude');
  }
}

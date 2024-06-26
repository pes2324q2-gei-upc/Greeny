import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Friends/friend_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:greeny/Map/add_review.dart';
import 'package:greeny/utils/utils.dart';

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
  List<dynamic> reviewsList = [];

  String currentUsername = '';

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
      return RefreshIndicator(
          onRefresh: getInfo,
          child: Scaffold(
            appBar: AppBar(
              title: Text(station['name']),
            ),
            body: SingleChildScrollView(
              // Add this
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    rating(),
                    specificInfo(),
                    reviews(),
                  ],
                ),
              ),
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
              const SizedBox(width: 5),
              Text(
                '(${reviewsList.length.toString()})',
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
            //review_list(),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.48, // Set the height to 50% of the screen height
              child: reviewList(),
            )
          ],
        ));
  }

  reviewList() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: reviewsList.map((review) {
          return Card(
            color: Theme.of(context).colorScheme.inversePrimary,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendProfilePage(
                                    friendUsername: review['author_username']),
                              ));
                        },
                        child: Text(
                          '@${review['author_username']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(review['puntuation'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      const Icon(Icons.star, color: Colors.yellow),
                      if (currentUsername != review['author_username'])
                        IconButton(
                          onPressed: () => _showConfirmDialog(review),
                          icon: const Icon(Icons.report),
                        )
                    ],
                  ),
                ),
                review['body'].isEmpty
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            review['body'],
                            textAlign: TextAlign.left,
                          ),
                        ),
                      )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  addReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddReviewPage(
              stationId: stationId, type: type, stationName: station['name'])),
    ).then((_) {
      getInfo();
    });
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
                  constraints: BoxConstraints.tight(const Size(45, 45)),
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
      case 'L6':
        return const Color.fromARGB(255, 119, 117, 180);
      case 'L7':
        return const Color.fromARGB(255, 160, 75, 9);
      case 'L8':
        return const Color.fromARGB(255, 231, 150, 191);
      case 'L9':
        return const Color.fromARGB(255, 234, 146, 53);
      case 'L9N':
        return const Color.fromARGB(255, 234, 146, 53);
      case 'L12':
        return const Color.fromARGB(255, 191, 190, 224);
      case 'S1':
        return const Color.fromARGB(255, 236, 103, 8);
      case 'S2':
        return const Color.fromARGB(255, 136, 189, 37);
      case 'S3':
        return const Color.fromARGB(255, 68, 142, 153);
      case 'S4':
        return const Color.fromARGB(255, 155, 130, 2);
      case 'S8':
        return const Color.fromARGB(255, 60, 186, 220);
      case 'S9':
        return const Color.fromARGB(255, 235, 75, 111);
      case 'R1':
        return const Color.fromARGB(255, 120, 179, 224);
      case 'R2':
        return const Color.fromARGB(255, 0, 150, 64);
      case 'R2N':
        return const Color.fromARGB(255, 162, 198, 22);
      case 'R2S':
        return const Color.fromARGB(255, 1, 95, 38);
      case 'R3':
        return const Color.fromARGB(255, 212, 66, 52);
      case 'R5':
        return const Color.fromARGB(255, 0, 149, 166);
      case 'R4':
        return const Color.fromARGB(255, 234, 166, 73);
      case 'R7':
        return const Color.fromARGB(255, 182, 130, 178);
      case 'R8':
        return const Color.fromARGB(255, 123, 22, 97);
      case 'R11':
        return const Color.fromARGB(255, 41, 98, 162);
      case 'R12':
        return const Color.fromARGB(255, 249, 222, 75);
      case 'R13':
        return const Color.fromARGB(255, 214, 67, 136);
      case 'R14':
        return const Color.fromARGB(255, 102, 81, 152);
      case 'R15':
        return const Color.fromARGB(255, 152, 140, 120);
      case 'R16':
        return const Color.fromARGB(255, 163, 36, 55);
      case 'R17':
        return const Color.fromARGB(255, 217, 120, 45);
      case 'R50':
        return const Color.fromARGB(255, 38, 126, 150);
      case 'R60':
        return const Color.fromARGB(255, 80, 83, 92);
      case 'RG1':
        return const Color.fromARGB(255, 48, 111, 199);
      case 'RT1':
        return const Color.fromARGB(255, 88, 193, 179);
      case 'RT2':
        return const Color.fromARGB(255, 215, 125, 199);
      case 'RL3':
        return const Color.fromARGB(255, 149, 147, 45);
    }
    switch (line[0]) {
      case 'T':
        return const Color.fromARGB(255, 61, 139, 121);
      case 'R':
        return const Color.fromARGB(255, 111, 110, 110);
      case 'S':
        return const Color.fromARGB(255, 151, 215, 0);
      case 'L':
        return const Color.fromARGB(255, 111, 110, 110);
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
      case 'L':
        {
          Uri tmbUri = Uri.parse(
              'https://www.tmb.cat/ca/barcelona/metro/-/lineametro/$line');
          if (await canLaunchUrl(tmbUri)) {
            await launchUrl(tmbUri);
          } else {
            throw 'Could not launch $tmbUri';
          }
        }
      case 'R':
        {
          var lineLower = line.toLowerCase();
          Uri tmbUri = Uri.parse(
              'https://rodalies.gencat.cat/es/linies_estacions_i_trens/index.html?linia=$lineLower');
          if (await canLaunchUrl(tmbUri)) {
            await launchUrl(tmbUri);
          } else {
            throw 'Could not launch $tmbUri';
          }
        }
    }
  }

  Future<void> getInfo() async {
    currentUsername = await UserAuth().getUserInfo('username');
    var responseStation = await httpGet('api/stations/$stationId');
    if (responseStation.statusCode == 200) {
      String body = utf8.decode(responseStation.bodyBytes);
      station = jsonDecode(body);
      var responseReviews = await httpGet('api/stations/$stationId/reviews/');
      if (responseStation.statusCode == 200) {
        String body = utf8.decode(responseReviews.bodyBytes);
        reviewsList = jsonDecode(body);
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
    if (mounted) {
      showMessage(context, translate('Error loading station'));
    }
  }

  void _sendReport(review) async {
    var reviewID = review['id'];
    var res = await httpPost(
        'api/stations/$stationId/reviews/$reviewID/profanity-filter',
        jsonEncode({}),
        'application/json');
    if (res.statusCode == 200) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      showMessage(context, translate('The review has been reported'));
    }
  }

  void _showConfirmDialog(review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate("Are you sure?")),
        content: Text(
            translate(
              "Are you sure you want to report this review?",
            ),
            textAlign: TextAlign.justify),
        actions: <Widget>[
          TextButton(
            onPressed: () => _sendReport(review),
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
}

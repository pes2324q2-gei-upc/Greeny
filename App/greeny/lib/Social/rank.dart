import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Friends/friends.dart';
import 'package:greeny/Social/podium.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    try {
      // Hacer la solicitud a la API
      final response = await httpGet('/api/ranking/');
      if (response.statusCode == 200) {
        // Analizar la respuesta JSON
        final List<dynamic> jsonData = json.decode(response.body);
        final List<User> users = jsonData.map((e) => User.fromJson(e)).toList();
        setState(() {
          _users = users;
        });
      } else {
        throw Exception('Failed to load ranking');
      }
    } catch (error) {
      print('Error fetching ranking: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: AppBar(
          title: Text(translate('Ranking'),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline_rounded),
              color: const Color.fromARGB(255, 1, 167, 164),
              onPressed: () {
                friends();
              },
            )
          ],
        ),
        body: _users.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal:
                          20.0), // Ajusta el valor del margen según sea necesario
                  child: Column(
                    children: [
                      // Usuarios en el podio
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (_users != null) ...[
                                if (_users.length > 1)
                                  Transform.scale(
                                    scale: 0.65,
                                    child: PodiumAvatar(
                                      profileImage: _users[1].avatar,
                                      rank: 2,
                                      username: _users[1].username,
                                      points: _users[1].points,
                                    ),
                                  ),
                                if (_users.isNotEmpty)
                                  PodiumAvatar(
                                    profileImage: _users[0].avatar,
                                    rank: 1,
                                    username: _users[0].username,
                                    points: _users[0].points,
                                  ),
                                if (_users.length > 2)
                                  Transform.scale(
                                    scale: 0.65,
                                    child: PodiumAvatar(
                                      profileImage: _users[2].avatar,
                                      rank: 3,
                                      username: _users[2].username,
                                      points: _users[2].points,
                                    ),
                                  ),
                              ],
                            ]),
                      ),
                      SizedBox(
                          height:
                              20), // Espacio entre el podio y la lista de usuarios restantes

                      // Lista de usuarios restantes
                      Expanded(
                        child: ListView.builder(
                          itemCount: _users.length > 3 ? _users.length - 3 : 0,
                          itemBuilder: (context, index) {
                            final user = _users[index + 3];
                            return ListTile(
                              title: Text(user.username),
                              subtitle: Text('Points: ${user.points}'),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user.avatar),
                                radius: 25,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  void friends() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FriendsPage()));
  }
}

class User {
  final String avatar;
  final String username;
  final int points;

  User({required this.avatar, required this.username, required this.points});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      avatar: json['image'],
      username: json['username'],
      points: json['points'],
    );
  }
}

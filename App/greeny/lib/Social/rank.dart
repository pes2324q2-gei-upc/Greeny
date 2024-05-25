import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Friends/friend_profile.dart';
import 'package:greeny/Friends/friends.dart';
import 'package:greeny/Social/podium.dart';
import 'package:http/http.dart';

Color greenyColor = const Color.fromARGB(255, 1, 167, 164);

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List<User> _users = [];
  int _userPosition = 0;
  bool _filterFriends = false;
  int friendRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
    getFriendsRequests();
  }

  Future<void> getFriendsRequests() async {
    friendRequestsCount = 0;

    try {
      const String endpointRequests = '/api/friend-requests/';
      final responseRequests = await httpGet(endpointRequests);

      if (responseRequests.statusCode == 200) {
        final List<dynamic> friendRequestsData =
            jsonDecode(responseRequests.body);
        setState(() {
          friendRequestsCount = friendRequestsData.length;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _fetchRanking() async {
    try {
      final Map<String, String> queryParams = {
        'filter': _filterFriends ? 'friends' : 'all',
      };

      // Hacer la solicitud a la API utilizando httpGetParams
      final response = await httpGetParams('/api/ranking/', queryParams);
      if (response.statusCode == 200) {
        // Analizar la respuesta JSON
        final jsonData = json.decode(response.body);

        // Obtener la lista de usuarios del campo 'ranking' en la respuesta JSON
        final List<dynamic> rankingData = jsonData['ranking'];
        final List<User> users =
            rankingData.map((e) => User.fromJson(e)).toList();

        // Obtener la posición del usuario en el ranking
        final int userPosition = jsonData['user_position'];

        setState(() {
          _users = users;
          _userPosition = userPosition;
        });
      } else {
        throw Exception('Failed to load ranking');
      }
    } catch (error) {
      print('Error fetching ranking: $error');
    }
  }

  void _toggleFilter(bool filterFriends) {
    setState(() {
      _filterFriends = filterFriends;
      _fetchRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        title: Text(
          translate('Ranking'),
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.people_outline_rounded),
                if (friendRequestsCount > 0)
                  Positioned(
                    left: 10,
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        friendRequestsCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            color: const Color.fromARGB(255, 1, 167, 164),
            onPressed: () {
              friends();
            },
          ),
        ],
      ),
      body: _users.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: getFriendsRequests,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal:
                          20.0), // Ajusta el valor del margen según sea necesario
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () => _toggleFilter(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _filterFriends
                                  ? Colors.grey[300]
                                  : const Color.fromARGB(255, 1, 167, 164),
                            ),
                            child: Text(translate('All')),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _toggleFilter(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _filterFriends
                                  ? const Color.fromARGB(255, 1, 167, 164)
                                  : Colors.grey[300],
                            ),
                            child: Text(translate('Friends')),
                          ),
                        ],
                      ),
                      // Usuarios en el podio
                      SizedBox(
                        height: 250,
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
                                    mastery: _users[1].mastery,
                                    level: _users[1].level,
                                  ),
                                ),
                              if (_users.isNotEmpty)
                                PodiumAvatar(
                                  profileImage: _users[0].avatar,
                                  rank: 1,
                                  username: _users[0].username,
                                  points: _users[0].points,
                                  mastery: _users[0].mastery,
                                  level: _users[0].level,
                                ),
                              if (_users.length > 2)
                                Transform.scale(
                                  scale: 0.65,
                                  child: PodiumAvatar(
                                    profileImage: _users[2].avatar,
                                    rank: 3,
                                    username: _users[2].username,
                                    points: _users[2].points,
                                    mastery: _users[2].mastery,
                                    level: _users[2].level,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          '${translate('Congrats, you are in position')} #$_userPosition!',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Lista de usuarios restantes
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    _users.length > 3 ? _users.length - 3 : 0,
                                itemBuilder: (context, index) {
                                  final user = _users[index + 3];
                                  return GestureDetector(
                                    onTap: () => clickCard(user
                                        .username), // Llama a la función clickCard con el usuario correspondiente
                                    child: Card(
                                      color: greenyColor,
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${index + 4}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 10),
                                            CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(user.avatar),
                                              radius: 25,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user.username,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color:
                                                              Colors.grey[300],
                                                          size: 20,
                                                        ),
                                                        Text(
                                                          user.level.toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .military_tech_rounded,
                                                          color:
                                                              Colors.grey[300],
                                                          size: 20,
                                                        ),
                                                        Text(
                                                          toRoman(
                                                              user.mastery + 1),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${user.points} pts',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void friends() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const FriendsPage())).then((_) {
      getFriendsRequests();
    });
  }

  void clickCard(String username) {
    // Navegar a la página de perfil del usuario
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FriendProfilePage(friendUsername: username),
        )).then((_) {
      getFriendsRequests();
    });
  }
}

String toRoman(int number) {
  // number must be 1, 2, 3 or 4.
  switch (number) {
    case 1:
      return 'I';
    case 2:
      return 'II';
    case 3:
      return 'III';
    case 4:
      return 'IV';
    default:
      return '0';
  }
}

class User {
  final String avatar;
  final String username;
  final int points;
  final int mastery;
  final int level;

  User(
      {required this.avatar,
      required this.username,
      required this.points,
      required this.mastery,
      required this.level});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      avatar: json['image'],
      username: json['username'],
      points: json['points'],
      mastery: json['mastery'],
      level: json['level'],
    );
  }
}

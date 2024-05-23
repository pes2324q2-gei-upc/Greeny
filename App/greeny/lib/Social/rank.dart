import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/Friends/friends.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  @override
  void initState() {
    super.initState();
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
        body: Center(
          child: Column(),
        ));
  }

  void friends() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FriendsPage()));
  }
}

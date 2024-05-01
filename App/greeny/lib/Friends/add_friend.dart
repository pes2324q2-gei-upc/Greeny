import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Friends/friend_profile.dart';
import 'package:greeny/Profile/profile.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:greeny/translate.dart' as t;

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  String _friendUsername = '';
  String userUsername = '';

  Future<void> getInfoUser() async {
    List<dynamic> userData = [];

    final response = await httpGet('/api/user/');

    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body);
        userUsername = userData[0]['username'];
      });
    } else {
      showMessage("Error loading user info");
    }
  }

  @override
  void initState() {
    getInfoUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 1, 167, 164),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  _friendUsername = value;
                });
              },
              decoration: InputDecoration(
                labelText: translate('Username'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                searchFriend(_friendUsername);
              },
              child: Text(translate('Search Profile')),
            ),
          ],
        ),
      ),
    );
  }

  void searchFriend(String username) async {
    if (username.isEmpty) {
      showMessage(translate('Please enter a username'));
      return;
    }
    if (username == userUsername) {
      showMessage(translate('You cannot add yourself as a friend'));
      return;
    }
    if (userUsername == '') {
      showMessage(translate('Error, please try again'));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              FriendProfilePage(friendUsername: username, isFriend: false)),
    );
  }

  void showMessage(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate(m)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}

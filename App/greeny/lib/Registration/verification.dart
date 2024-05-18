import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Registration/sign_up.dart';
import 'package:greeny/main_page.dart';
import 'package:greeny/utils/utils.dart';
import '../utils/translate.dart' as t;
import 'package:greeny/API/user_auth.dart';

String backendURL = dotenv.env['BACKEND_URL']!;

getBackendURL() {
  return backendURL;
}

class VerificationPage extends StatefulWidget {
  final String username;
  final String password;
  final String email;

  const VerificationPage(
      {super.key,
      required this.username,
      required this.password,
      required this.email});

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  final TextEditingController verificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(translate('Welcome to Greeny!')),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () {
                t.showLanguageDialog(context);
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Text(
                  translate(
                    'Introduce the verification code we\'ve sent you to the email: ${widget.email}',
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextFormField(
                controller: verificationController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: translate('Enter your verification code'),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submit,
                child: Text(translate('Submit')),
              ),
              TextButton(
                onPressed: _showExitDialog,
                child: Text(translate("Cancel registration")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate("Are you sure?")),
        content: Text(
            translate(
              "You will be redirected to the login page and your account will be deleted. "
              "Are you sure you want to cancel the registration?",
            ),
            textAlign: TextAlign.justify),
        actions: <Widget>[
          TextButton(
            onPressed: () => _deleteUser(widget.username),
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

  Future<void> _deleteUser(String username) async {
    final response = await httpDeleteNoToken(
        'api/delete_inactive_user/',
        jsonEncode({
          'username': username,
        }),
        'application/json');

    if (response.statusCode == 200) {
      print('User deleted successfully');
    } else {
      throw Exception('Failed to delete user');
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
      (Route<dynamic> route) => false,
    );
  }

  void submit() async {
    String username = widget.username;
    String password = widget.password;
    String verificationCode = verificationController.text;
    var response = await httpPostNoToken(
        'api/verify/',
        jsonEncode({
          'username': username,
          'verificationCode': verificationCode,
        }),
        'application/json');

    if (response.statusCode == 200) {
      var res = await UserAuth().userAuth(username, password);

      if (res) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          showMessage(context,
              translate('Could not log in. Please check your credentials'));
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content:
                Text('Failed to verify. The code is incorrect, try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
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
}

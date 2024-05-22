import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:greeny/Registration/verification.dart';
import 'package:greeny/utils/utils.dart';
import '../utils/translate.dart' as t;

class SendEmailPage extends StatefulWidget {
  const SendEmailPage({super.key});

  @override
  SendEmailPageState createState() => SendEmailPageState();
}

class SendEmailPageState extends State<SendEmailPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                translate('Enter the email you used to sign up'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: translate('Enter your email'),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _submit,
              child: Text(translate('Submit')),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _showExitDialog,
              child: Text(translate("Cancel")),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    String email = emailController.text;
    var response = await httpPostNoToken(
        'api/forgot_password/',
        jsonEncode({
          'email': email,
        }),
        'application/json');

    if (response.statusCode == 200) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerificationPage(email: email, resetPassword: true),
        ),
      );
    } else {
      if (!mounted) return;
      showMessage(
          context,
          translate(
              'The email you entered is not associated with any account. Please try again or create a new account'));
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate("Are you sure?")),
        content: Text(
          translate(
              'You will be redirected to the login page. Are you sure you want to cancel the password reset?'),
          textAlign: TextAlign.justify,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LogInPage()),
                (Route<dynamic> route) => false,
              );
            },
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:greeny/Registration/sign_up.dart';
import 'package:greeny/utils/onboarding_page.dart';
import 'package:greeny/utils/utils.dart';
import '../utils/translate.dart' as t;
import 'package:greeny/API/user_auth.dart';

class VerificationPage extends StatefulWidget {
  final String? username;
  final String? password;
  final String email;
  final bool resetPassword;

  const VerificationPage(
      {super.key,
      this.username,
      this.password,
      required this.email,
      required this.resetPassword});

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  final TextEditingController verificationController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool showPasswordResetFields = false;
  final newPasswordForm = GlobalKey<FormState>();

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
              const SizedBox(height: 20),
              if (!showPasswordResetFields) ...[
                Text(
                  '${translate('Introduce the verification code we have sent you to the email')} ${widget.email}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: verificationController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: translate('Enter your verification code'),
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _submitCode,
                  child: Text(translate('Submit')),
                ),
              ],
              if (showPasswordResetFields) ...[
                Form(
                  key: newPasswordForm,
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          translate('Enter your new password and confirm it'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        obscureText: true,
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: translate('Enter your new password'),
                        ),
                        validator: (value) => validator(value, 'password'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        obscureText: true,
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: translate('Confirm your new password'),
                        ),
                        validator: passwordConfirmValidator,
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: _submitNewPassword,
                        child: Text(translate('Submit')),
                      ),
                    ],
                  ),
                )
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: _showExitDialog,
                child: Text(translate("Cancel")),
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
          widget.resetPassword
              ? translate(
                  'You will be redirected to the login page. Are you sure you want to cancel the password reset?')
              : translate(
                  "You will be redirected to the login page and your account will be deleted. "
                  "Are you sure you want to cancel the registration?",
                ),
          textAlign: TextAlign.justify,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (widget.resetPassword) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LogInPage()),
                  (Route<dynamic> route) => false,
                );
              } else {
                if (widget.username != null) {
                  _deleteUser(widget.username!);
                }
              }
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

  Future<void> _deleteUser(String username) async {
    await httpDeleteNoToken(
        'api/cancel_registration/',
        jsonEncode({
          'username': username,
        }),
        'application/json');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _submitNewPassword() async {
    if (newPasswordForm.currentState!.validate()) {
      String newPassword = newPasswordController.text;

      var response = await httpPostNoToken(
          'api/reset_password/',
          jsonEncode({
            'email': widget.email,
            'new_password': newPassword,
          }),
          'application/json');

      if (response.statusCode == 200) {
        if (mounted) {
          showMessage(context, translate('Password successfully changed'));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LogInPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (!mounted) return;
        showMessage(context, translate('Failed to reset password. Try again'));
      }
    }
  }

  void _submitCode() async {
    if (widget.resetPassword) {
      _submitResetPassword();
    } else {
      _submitRegistration();
    }
  }

  void _submitResetPassword() async {
    String verificationCode = verificationController.text;
    var response = await httpPostNoToken(
        'api/verify_forgotten_password/',
        jsonEncode({
          'email': widget.email,
          'verificationCode': verificationCode,
        }),
        'application/json');

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          showPasswordResetFields = true;
        });
      }
    } else {
      if (!mounted) return;
      showMessage(context,
          translate('Failed to verify. The code is incorrect, try again'));
    }
  }

  void _submitRegistration() async {
    String username = widget.username!;
    String password = widget.password!;
    String verificationCode = verificationController.text;
    var response = await httpPostNoToken(
        'api/verify_registration/',
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
            MaterialPageRoute(builder: (context) => const OnboardingPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          showMessage(context,
              translate('Could not sign up. Please check your credentials'));
        }
      }
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translate('Error')),
            content: Text(translate(
                'Failed to verify. The code is incorrect, try again.')),
            actions: <Widget>[
              TextButton(
                child: Text(translate('Ok')),
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

  String? passwordConfirmValidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your password');
    } else if (newPasswordController.text != confirmPasswordController.text) {
      return translate('Passwords do not match');
    }
    return null;
  }
}

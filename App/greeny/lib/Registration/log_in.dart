import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'sign_up.dart';
import '../main_page.dart';
import '../utils/translate.dart' as t;
import '../API/user_auth.dart';
import 'package:greeny/utils/utils.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final logInForm = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(40, 50, 40, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Form(
                      key: logInForm,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  translate('Log In'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ]),
                          const SizedBox(height: 30),
                          TextFormField(
                            obscureText: false,
                            controller: usernameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Username'),
                            ),
                            validator: usernameValidator,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Password'),
                            ),
                            validator: passwordValidator,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: forgotPassword,
                                child: Text(translate('Forgot password?')),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: sendLogIn,
                            child: Text(translate('Log In')),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Text(
                          '${translate('Or sign in with')}:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        IconButton(
                          icon: const Image(
                            image: AssetImage('assets/icons/google.png'),
                            height: 40,
                            width: 40,
                          ),
                          iconSize: 30,
                          tooltip: translate('Sign in with Google'),
                          onPressed: googleSignIn,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(children: [
                          Text(
                            translate("Don't have an account?"),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: (signUpHere),
                            child: Text(translate('Sign Up here')),
                          )
                        ])
                      ],
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your username');
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your password');
    }
    return null;
  }

  Future<void> sendLogIn() async {
    if (logInForm.currentState!.validate()) {
      final username = usernameController.text;
      final password = passwordController.text;
      bool ok = await UserAuth().userAuth(username, password);
      if (ok) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          showMessage(context, translate('Could not log in. Please check your credentials'));
        }
      }
    }
  }

  Future<void> googleSignIn() async {}

  Future<void> forgotPassword() async {}

  Future<void> signUpHere() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }
}

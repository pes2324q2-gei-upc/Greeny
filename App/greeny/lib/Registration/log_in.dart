import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'sign_up.dart';
import '../main_page.dart';
import '../translate.dart' as t;

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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
                    Column(
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
                        TextField(
                          obscureText: false,
                          controller: usernameController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: translate('Username'),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: translate('Password'),
                          ),
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

  Future<void> sendLogIn() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> googleSignIn() async {
    print('Signing in with Google');
  }

  Future<void> forgotPassword() async {
    print('Forgot password');
  }

  Future<void> signUpHere() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }
}

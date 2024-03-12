import 'package:flutter/material.dart';
import 'sign_up.dart';
import '../main_page.dart';

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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Welcome to Greeny!'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                        'Log In',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ]),
                    const SizedBox(
                      height: 40,
                    ),
                    TextField(
                      obscureText: false,
                      controller: usernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: sendLogIn,
                      child: const Text('Log In'),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'Or continue with:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Image(
                        image: AssetImage('assets/icons/google.png'),
                        height: 40,
                        width: 40,
                    ),
                    tooltip: 'Sign in with Google',
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
                      "You don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: (signUpHere),
                      child: const Text('Sign Up here'),
                    )
                  ])
                ],
              )
            ],
          ),
        ));
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

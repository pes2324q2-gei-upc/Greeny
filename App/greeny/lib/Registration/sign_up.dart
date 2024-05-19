import 'package:flutter/material.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Registration/verification.dart';
import 'log_in.dart';
import '../utils/translate.dart' as t;
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/utils/utils.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final nameContoller = TextEditingController();

  final signUpForm = GlobalKey<FormState>();

  bool _loading = false;

  ValueNotifier userCredential = ValueNotifier('');

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameContoller.dispose();
    usernameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    emailController.dispose();
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
      body: _loading == false
          ? buildSignInForm()
          : const Center(child: CircularProgressIndicator()
    ));
  }

  Widget buildSignInForm() {
    return CustomScrollView(
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
                      key: signUpForm,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  translate('Sign Up'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ]),
                          SizedBox(
                            height: MediaQuery.of(context)
                                    .devicePixelRatio
                                    .toInt() *
                                13,
                          ),
                          TextFormField(
                            obscureText: false,
                            controller: nameContoller,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Name'),
                            ),
                            validator: (value) => validator(value, 'name'),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            obscureText: false,
                            controller: emailController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Email Address'),
                            ),
                            validator: emailValidator,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            obscureText: false,
                            controller: usernameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Username'),
                            ),
                            validator: (value) => validator(value, 'username'),
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
                            validator: (value) => validator(value, 'password'),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: passwordConfirmController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Confirm Password'),
                            ),
                            validator: passwordConfirmValidator,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: sendSignUp,
                            child: Text(translate('Sign Up')),
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
                          onPressed: googleLogIn,
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
                            translate("Already have an account?"),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: (logInHere),
                            child: Text(translate('Log In here')),
                          )
                        ])
                      ],
                    )
                  ],
                ),
              )),
        ],
      );
  }

  Future<void> sendSignUp() async {
    if (signUpForm.currentState!.validate()) {
      final username = usernameController.text;
      final password = passwordController.text;
      final email = emailController.text;
      final name = nameContoller.text;
      setState(() {
        _loading = true;
      });

      String res =
          await UserAuth().userRegister(name, username, email, password);
      checkSuccess(res);
    }
  }

  Future<void> googleLogIn() async {
    setState(() {
        _loading = true;
      });
    bool ok = await UserAuth().userGoogleAuth();
    checkSuccess(ok ? 'ok' : 'Could not log in. Please try it later');
  }

  void checkSuccess(String res) {
    if (res == 'ok') {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => VerificationPage(
                      username: usernameController.text,
                      password: passwordController.text,
                      email: emailController.text,
                    )),
            ModalRoute.withName('/'),
          );
        }
      } else {
        if (mounted) {
          showMessage(context, translate(res));
        }
      }
  }

  Future<void> logInHere() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogInPage()),
    );
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your email');
    }

    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value.isNotEmpty && !regex.hasMatch(value)
        ? translate('Enter a valid email address')
        : null;
  }

  String? passwordConfirmValidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your password');
    } else if (passwordController.text != passwordConfirmController.text) {
      return translate('Passwords do not match');
    }
    return null;
  }
}

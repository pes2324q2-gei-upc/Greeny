import 'package:google_sign_in/google_sign_in.dart';

void googleSign() async {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  _googleSignIn.signIn().then((result) {
    result?.authentication.then((googleKey) {
      print(googleKey.accessToken);
      print(googleKey.idToken);
      print(_googleSignIn.currentUser?.displayName);
      print(_googleSignIn.currentUser?.email);
    }).catchError((err) {
      print('inner error');
    });
  }).catchError((err) {
    print('error occured');
  });
}

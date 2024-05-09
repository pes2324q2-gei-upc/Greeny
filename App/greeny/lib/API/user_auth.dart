import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:greeny/API/secure_storage.dart';
import 'package:greeny/API/requests.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserAuth {
  Future userAuth(String username, String password) async {
    var backendURL = Uri.http(dotenv.env['BACKEND_URL']!, 'api/token/');
    var response = await http.post(
      backendURL,
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      await userSaveTokens(json['access'], json['refresh']);
      return true;
    } else {
      return false;
    }
  }

  /*Future<bool> userGoogleAuth() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
      ],
    );

    try {
      final GoogleSignInAccount? result = await googleSignIn.signIn();
      if (result != null) {
        final GoogleSignInAuthentication googleKey =
            await result.authentication;
        print('access');
        print(googleKey.idToken);
        return await backendGoogleAuth(googleKey.idToken!);
      }
    } catch (err) {
      print(err.toString());
      return false;
    }
    return false;
  }*/

  Future<bool> userGoogleAuth() async {
    final googleAccount = await GoogleSignIn().signIn();

    final googleAuth = await googleAccount?.authentication;

    if (googleAuth != null && googleAuth.idToken != null) {
      return await backendGoogleAuth(googleAuth.idToken!);
    }
    return false;
  }

  Future<bool> backendGoogleAuth(String idToken) async {
    var backendURL = Uri.http(dotenv.env['BACKEND_URL']!, 'api/oauth2/');
    var response = await http.post(
      backendURL,
      body: {'token': idToken},
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      await userSaveTokens(json['access'], json['refresh']);
      return true;
    } else {
      return false;
    }
  }

  Future<String> userRegister(
      String name, String username, String email, String password) async {
    var backendURL = Uri.http(dotenv.env['BACKEND_URL']!, 'api/user/');
    var response = await http.post(
      backendURL,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'first_name': name,
        'username': username,
        'email': email,
        'password': password
      }),
    );
    if (response.statusCode == 201) {
      await userAuth(username, password);
      return 'ok';
    } else {
      Map json = jsonDecode(response.body);
      if (json.containsKey("email")) {
        return (json["email"][0]);
      } else if (json.containsKey("username")) {
        return (json["username"][0]);
      }
      return 'ko';
    }
  }

  Future userSaveTokens(String accessToken, String refreshToken) async {
    await SecureStorage().writeSecureData('access_token', accessToken);
    await SecureStorage().writeSecureData('refresh_token', refreshToken);
  }

  Future userLogout() async {
    await SecureStorage().deleteSecureData('access_token');
    await SecureStorage().deleteSecureData('refresh_token');
  }

  Future userDelete() async {
    var response = await httpDelete('api/user/');
    if (response.statusCode == 200) {
      await userLogout();
      return true;
    } else {
      return false;
    }
  }
}

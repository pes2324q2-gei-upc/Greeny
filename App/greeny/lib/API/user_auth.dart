import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greeny/API/secure_storage.dart';
import 'package:greeny/API/requests.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserAuth {
  //Function to authenticate the user with username and password and get the access token
  Future userAuth(String username, String password) async {
    var data = jsonEncode({
      'username': username,
      'password': password,
    });
    var response =
        await httpPostNoToken('api/token/', data, 'application/json');
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      await userSaveInfo(json['access'], json['refresh'], username);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> userGoogleAuth() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      var res = await FirebaseAuth.instance.signInWithCredential(credential);
      var idToken = await res.user?.getIdToken();

      if (idToken != null) {
        return await backendGoogleAuth(idToken);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> backendGoogleAuth(String idToken) async {
    var data = jsonEncode({
      'token': idToken,
    });
    var response =
        await httpPostNoToken('api/oauth2/', data, 'application/json');
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      await userSaveInfo(json['access'], json['refresh'], json['username']);
      return true;
    } else {
      return false;
    }
  }

  Future<String> userRegister(
      String name, String username, String email, String password) async {
    var data = jsonEncode({
      'first_name': name,
      'username': username,
      'email': email,
      'password': password
    });
    var response = await httpPostNoToken('api/user/', data, 'application/json');
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

  Future getUserInfo(String key) {
    return SecureStorage().readSecureData(key);
  }

  Future userSaveInfo(
      String accessToken, String refreshToken, String username) async {
    await SecureStorage().writeSecureData('access_token', accessToken);
    await SecureStorage().writeSecureData('refresh_token', refreshToken);
    await SecureStorage().writeSecureData('username', username);
  }

  Future userLogout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await SecureStorage().deleteSecureData('access_token');
    await SecureStorage().deleteSecureData('refresh_token');
    await SecureStorage().deleteSecureData('username');
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

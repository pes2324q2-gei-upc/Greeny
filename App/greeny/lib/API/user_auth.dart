import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:greeny/API/secure_storage.dart';
import 'package:greeny/API/requests.dart';

class UserAuth {
  Future userAuth(String username, String password) async {
    var backendURL = Uri.http(dotenv.env['BACKEND_URL']!, 'api-token-auth/');
    var response = await http.post(
      backendURL,
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      var valor = json['token'];
      await SecureStorage().writeSecureData('token', valor);
      await getUserInfo();
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
        'name': name,
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

  Future userLogout() async {
    await SecureStorage().deleteSecureData('token');
    await SecureStorage().deleteSecureData('name');
  }

  getUserInfo() async {
    var response = await httpGet('api/user/');
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      await writeUserData(json);
    } else {
      return 'No data found!';
    }
  }

  writeUserData(Map info) async {
    await SecureStorage().writeSecureData('name', info['name']);
  }

  Future<String> readUserInfo(String key) async {
    String value = await SecureStorage().readSecureData(key);
    return value;
  }
}

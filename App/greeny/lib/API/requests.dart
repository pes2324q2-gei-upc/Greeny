import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greeny/API/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

String backendURL = dotenv.env['BACKEND_URL']!;

Future<String> getToken() async {
  String? access = await SecureStorage().readSecureData('access_token');
  if (access == null) return '';
  bool hasExpired = JwtDecoder.isExpired(access);
  /* Si el token ha expirado, se obtiene un nuevo token con el refresh token */
  /* Si el refresh token ha expirado, se devuelve un string vacío */
  if (hasExpired) {
    String refresh = await SecureStorage().readSecureData('refresh_token');
    var uri = Uri.http(backendURL, 'api/token/refresh/');
    var response = await http.post(
      uri,
      body: {'refresh': refresh},
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      await SecureStorage().writeSecureData('access_token', json['access']);
      return json['access'];
    } else {
      return '';
    }
  } else {
    return access;
  }
}

httpGet(String url) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  return response;
}

httpPost(String url, String params, String contentType) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': contentType,
    },
    body: params,
  );

  return response;
}

httpPut(String url, String params) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: params,
  );
  return response;
}

httpPatch(String url, String params) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.patch(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
    body: params,
  );
  return response;
}

Future<bool> checkConnection() async {
  var uri = Uri.http(backendURL, 'api/');
  try {
    await http.get(uri);
    return true;
  } catch (e) {
    return false;
  }
}

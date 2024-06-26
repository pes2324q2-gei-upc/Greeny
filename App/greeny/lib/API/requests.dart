import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greeny/API/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'dart:async';

String backendURL = dotenv.env['BACKEND_URL']!;

final StreamController<bool> bannedUserController =
    StreamController<bool>.broadcast();

getBackendURL() {
  return backendURL;
}

Future<String> getToken() async {
  String? access = await SecureStorage().readSecureData('access_token');
  if (access == null) return '';
  bool hasExpired = JwtDecoder.isExpired(access);
  /* Si el token ha expirado, se obtiene un nuevo token con el refresh token */
  /* Si el refresh token ha expirado o no hay access, se devuelve un string vacío */
  if (hasExpired) {
    String refresh = await SecureStorage().readSecureData('refresh_token');
    var uri = Uri.http(backendURL, 'api/token/refresh/');
    final response = await http.post(
      uri,
      body: {'refresh': refresh},
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      await SecureStorage().writeSecureData('access_token', json['access']);
      return json['access'];
    } else if (response.statusCode == 423) {
      return 'banned';
    } else {
      return '';
    }
  } else {
    return access;
  }
}

Future<bool> checkTokenFirstTime(token) async {
  var uri = Uri.http(backendURL, 'api/user/');
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  return response.statusCode == 200;
}

httpGetParams(String url, Map<String, String> params) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url, params);
  var response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  checkForBan(response);

  return response;
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
  checkForBan(response);

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

  checkForBan(response);

  return response;
}

httpPostNoToken(String url, String params, String contentType) async {
  var uri = Uri.http(backendURL, url);
  var response = await http.post(
    uri,
    headers: {
      'Content-Type': contentType,
    },
    body: params,
  );
  checkForBan(response);
  return response;
}

httpPut(String url, String params, String type) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.put(
    uri,
    headers: {
      'Content-Type': type,
      'Authorization': 'Bearer $token',
    },
    body: params,
  );

  checkForBan(response);

  return response;
}

httpPatch(String url, String params, String type) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.patch(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': type,
    },
    body: params,
  );

  checkForBan(response);

  return response;
}

httpDelete(String url) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.delete(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  checkForBan(response);

  return response;
}

httpDeleteNoToken(String url, String params, String contentType) async {
  var uri = Uri.http(backendURL, url);
  var response = await http.delete(
    uri,
    headers: {
      'Content-Type': contentType,
    },
    body: params,
  );

  checkForBan(response);

  return response;
}

Future<bool> checkConnection() async {
  var uri = Uri.http(backendURL, 'api/ping');
  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

sendAcceptFriendRequest(int id) async {
  var uri = Uri.http(backendURL, '/api/friend-requests/$id/');
  var token = await getToken();
  final response = await http.delete(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization':
          'Bearer $token', // Agregar el token como un encabezado de autorización
    },
    body: jsonEncode(<String, dynamic>{
      'accept': 'true',
    }),
  );
  return response;
}

sendRejectFriendRequest(int id) async {
  var uri = Uri.http(backendURL, '/api/friend-requests/$id/');
  var token = await getToken();
  final response = await http.delete(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization':
          'Bearer $token', // Agregar el token como un encabezado de autorización
    },
    body: jsonEncode(<String, dynamic>{
      'accept': 'false',
    }),
  );
  return response;
}

httpUpdateAccount({
  String? firstName,
  String? username,
  String? currentPassword,
  String? newPassword,
  File? pickedImage,
  String? defaultImage,
}) async {
  var uri = Uri.http(backendURL, '/api/user/');
  final request = http.MultipartRequest('PATCH', uri);
  var token = await getToken();

  request.headers['Authorization'] = 'Bearer $token';

  if (firstName != null && firstName.isNotEmpty) {
    request.fields['first_name'] = firstName;
  }

  if (username != null && username.isNotEmpty) {
    request.fields['username'] = username;
  }

  if (currentPassword != null &&
      newPassword != null &&
      currentPassword.isNotEmpty &&
      newPassword.isNotEmpty) {
    request.fields['current_password'] = currentPassword;
    request.fields['new_password'] = newPassword;
  }

  if (pickedImage != null) {
    final bytes = pickedImage.readAsBytesSync();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: 'profile_pic.png',
      contentType: MediaType('image', 'png'),
    );
    request.files.add(multipartFile);
  }

  if (defaultImage != null && defaultImage.isNotEmpty) {
    request.fields['default_image'] = defaultImage;
  }

  final streamedResponse = await request.send();
  return await http.Response.fromStream(streamedResponse);
}

bool checkForBan(response) {
  if (response.statusCode == 423 ||
      (response.statusCode == 401 &&
          jsonDecode(response.body)['detail'] == 'User is inactive')) {
    bannedUserController.add(true);
    return true;
  }
  return false;
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greeny/API/secure_storage.dart';
import 'package:http/http.dart' as http;

String backendURL = dotenv.env['BACKEND_URL']!;

Future<String> getToken() async {
  return await SecureStorage().readSecureData('token');
}

httpGet(String url) async {
  var token = await getToken();
  var uri = Uri.http(backendURL, url);
  var response = await http.get(
    uri,
    headers: {
      'Authorization': 'Token $token',
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
      'Authorization': 'Token $token',
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
      'Authorization': 'Token $token',
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
      'Authorization': 'Token $token',
    },
    body: params,
  );
  return response;
}

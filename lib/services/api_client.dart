import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _baseUrl = 'http://127.0.0.1:5000';

  final http.Client httpClient = http.Client();

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token;
  }

  Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    final response = await httpClient.get(Uri.parse('$_baseUrl/$endpoint'), headers: {
      'Authorization': 'Bearer $token',
    });
    return response;
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await getToken();
    final response = await httpClient.post(Uri.parse('$_baseUrl/$endpoint'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }, body: jsonEncode(body));
    return response;
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await getToken();
    final response = await httpClient.put(Uri.parse('$_baseUrl/$endpoint'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }, body: jsonEncode(body));
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await getToken();
    final response = await httpClient.delete(Uri.parse('$_baseUrl/$endpoint'), headers: {
      'Authorization': 'Bearer $token',
    });
    return response;
  }
}

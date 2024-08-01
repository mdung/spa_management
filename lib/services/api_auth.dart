import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuth {
  static Future<void> checkTokenAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }
    final jwtPayload = _decodeJwtPayload(token);
    final expirationTime = jwtPayload['exp'] * 1000;
    if (DateTime.now().millisecondsSinceEpoch >= expirationTime) {
      await removeToken();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final String json = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(json);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}

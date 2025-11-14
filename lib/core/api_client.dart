import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth/TokenStore.dart';

class ApiClient {
  static const String baseUrl =
      'https://backend-taskmaster-1.onrender.com/';

  final http.Client _http;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await TokenStore.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  void _logResponse(http.Response res) {
    if (kDebugMode) {
      debugPrint('${res.request?.method} ${res.request?.url}');
      debugPrint(' status: ${res.statusCode}');
      debugPrint(' body:   ${res.body}');
    }
  }

  void _throwIfError(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'HTTP ${res.statusCode}: ${res.body}',
      );
    }
  }

  Future<http.Response> get(String path, {bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _http.get(
      uri,
      headers: await _headers(auth: auth),
    );
    _logResponse(res);
    _throwIfError(res);
    return res;
  }

  Future<http.Response> post(
      String path, {
        Object? body,
        bool auth = true,
      }) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _http.post(
      uri,
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    _logResponse(res);
    _throwIfError(res);
    return res;
  }

  Future<http.Response> put(
      String path, {
        Object? body,
        bool auth = true,
      }) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _http.put(
      uri,
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    _logResponse(res);
    _throwIfError(res);
    return res;
  }

  Future<http.Response> delete(
      String path, {
        Object? body,
        bool auth = true,
      }) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _http.delete(
      uri,
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    _logResponse(res);
    _throwIfError(res);
    return res;
  }
}

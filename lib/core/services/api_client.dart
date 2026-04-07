import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Thin HTTP client for the Xeboki POS API.
/// Base URL comes from [AppConfig.apiUrl] (dart-define at build time).
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  final String _base = AppConfig.apiUrl;

  Map<String, String> _headers({String? jwt}) => {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };

  /// POST /login — email + password → JWT + Firebase config + custom token
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _http.post(
      Uri.parse('$_base/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      throw ApiException(
        statusCode: res.statusCode,
        message: body['message'] as String? ?? 'Login failed',
      );
    }
    return body;
  }

  /// GET /sync/business-config — business config for the authenticated terminal
  Future<Map<String, dynamic>> getBusinessConfig(String jwt) async {
    final res = await _http.get(
      Uri.parse('$_base/sync/business-config'),
      headers: _headers(jwt: jwt),
    );
    if (res.statusCode != 200) {
      throw ApiException(statusCode: res.statusCode, message: 'Config fetch failed');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

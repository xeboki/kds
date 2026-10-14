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

  /// POST /auth/register-with-code — claim this device with a Quick Code.
  ///
  /// SPEC-097. The same endpoint a till uses; the code itself says a kitchen
  /// screen is being registered. Returns a `request_id` to poll — the device
  /// does not exist until somebody approves it in the back office.
  Future<Map<String, dynamic>> registerWithCode({
    required String code,
    required String email,
    required String password,
    required String deviceName,
    required String deviceId,
  }) async {
    final res = await _http.post(
      Uri.parse('$_base/auth/register-with-code'),
      headers: _headers(),
      body: jsonEncode({
        'code': code,
        'email': email,
        'password': password,
        'terminal_name': deviceName,
        'device_id': deviceId,
        'device_type': 'kds',
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        statusCode: res.statusCode,
        message: (body['detail'] ?? 'Registration failed').toString(),
      );
    }
    return body;
  }

  /// GET /auth/registration-status/{id} — has anybody approved us yet?
  Future<Map<String, dynamic>> registrationStatus(String requestId) async {
    final res = await _http.get(
      Uri.parse('$_base/auth/registration-status/$requestId'),
      headers: _headers(),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: (body['detail'] ?? 'Could not check registration').toString(),
      );
    }
    return body;
  }

  /// GET /kds/screen/{id} — what this screen is set up to show.
  ///
  /// `kds_screens` lives in Manager Firebase, which this app never signs into,
  /// so the role and the routing categories come from here.
  Future<Map<String, dynamic>> getScreenConfig({
    required String jwt,
    required String screenId,
  }) async {
    final res = await _http.get(
      Uri.parse('$_base/kds/screen/$screenId'),
      headers: _headers(jwt: jwt),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw ApiException(
        statusCode: res.statusCode,
        message: (body['detail'] ?? 'Could not load this screen').toString(),
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

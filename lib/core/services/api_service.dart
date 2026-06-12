import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  static const _baseUrl =
      'https://asia-southeast2-wargaku-dc0ad.cloudfunctions.net';

  static Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResult> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 30));
      return ApiResult.fromResponse(response);
    } catch (e) {
      return ApiResult(success: false, error: e.toString());
    }
  }

  static Future<ApiResult> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _headers(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      return ApiResult.fromResponse(response);
    } catch (e) {
      return ApiResult(success: false, error: e.toString());
    }
  }

  static Future<ApiResult> patch(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _headers(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      return ApiResult.fromResponse(response);
    } catch (e) {
      return ApiResult(success: false, error: e.toString());
    }
  }
}

class ApiResult {
  final bool success;
  final dynamic data;
  final String? error;

  ApiResult({required this.success, this.data, this.error});

  factory ApiResult.fromResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult(success: true, data: null);
      }
      return ApiResult(success: false, error: 'Server error (${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResult(success: true, data: body);
    }
    final errorMsg = body is Map ? body['error'] : null;
    return ApiResult(
      success: false,
      error: errorMsg?.toString() ?? 'Request failed (${response.statusCode})',
    );
  }
}

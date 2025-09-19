import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _storage;

  ApiService({
    required this.baseUrl,
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? _createHttpClient(),
        _storage = storage ?? const FlutterSecureStorage();

  // Create HTTP client that bypasses SSL certificate verification for development
  static http.Client _createHttpClient() {
    if (kIsWeb) {
      // For web, use the default HTTP client (no SSL bypass needed)
      return http.Client();
    } else {
      // For mobile platforms, create custom client that bypasses SSL verification
      final httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Allow all certificates in development mode
          // WARNING: This should only be used for development!
          return true;
        };
      return IOClient(httpClient);
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final headers = await _getHeaders();
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, {dynamic body}) async {
    final headers = await _getHeaders();
    final response = await _client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await _client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to parse response: ${e.toString()}',
        );
      }
    }
    
    throw ApiException(
      statusCode: response.statusCode,
      message: _parseErrorMessage(response),
    );
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic>) {
        return body['message'] ?? body['error'] ?? 'Unknown error occurred';
      }
      return response.body;
    } catch (e) {
      return response.body;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}

import 'import_export.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/io.dart';

class ApiService {
  static void setupDio() {
    final dio = Dio();
    
    // Configure SSL certificate validation bypass for development
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (dio.httpClientAdapter is IOHttpClientAdapter) {
        (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            // Allow all certificates in development mode
            // WARNING: This should only be used for development!
            return true;
          };
          return client;
        };
      }
    }
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add any authentication headers
          final token = Get.find<AuthController>().token.value;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle token expiration
            Get.find<AuthController>().logout();
            Get.offAllNamed(ROUTE_LOGIN);
          }
          return handler.next(error);
        },
      ),
    );
    Get.put(dio);
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';

class Constants {
  // Platform-specific base URLs
  static const String _webBaseUrl = 'https://localhost:7094/api';
  static const String _mobileBaseUrl = 'https://10.196.23.91:7094/api'; // Android emulator
  
  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return _webBaseUrl;
    } else if (Platform.isAndroid) {
      return _mobileBaseUrl;
    } else if (Platform.isIOS) {
      return _webBaseUrl; // iOS simulator can use localhost
    } else {
      return _webBaseUrl; // Default fallback
    }
  }
  
  // Event Comments Endpoints
  static const String eventComments = '/EventComments';
  static const String eventCommentsByEvent = '/EventComments/event';
  
  // Common HTTP headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

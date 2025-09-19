import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Platform-specific base URLs
  static const String _webBaseUrl = 'https://localhost:7094/api';
  static const String _mobileBaseUrl = 'https://10.26.71.9:7094/api'; // Android/physical device IP
  // For iOS simulator, use: 'https://localhost:7094/api'
  // For physical device, use your computer's IP: 'https://192.168.1.xxx:7094/api'
  
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
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String updateUser = '/auth/users/{userId}/update';
  
  // Events Endpoints
  static const String events = '/Events';
  static const String eventDetails = '/Events';  // /{id}
  static const String createEvent = '/Events';
  static const String updateEvent = '/Events';   // /{id}
  static const String invisibleEvents = '/Events/invisible';
  static const String eventStatus = '/Events/{id}/status';
  static const String eventVisibility = '/Events/{id}/visibility';
  
  // Categories Endpoints
  static const String categories = '/Categories';
  static const String activeCategories = '/Categories/active';
  
  // Event Invites Endpoints
  static const String invites = '/event-invites';
  static const String createInvite = '/event-invites';
  static const String updateInviteStatus = '/event-invites/{inviteId}/status';
  static const String userInvites = '/event-invites/user';  // /{userId}
  static const String pendingUserInvites = '/event-invites/pending/user';  // /{userId}
  static const String deleteInvite = '/event-invites/{inviteId}';
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import 'storage_service.dart';

class AutoLoginService {
  static Future<Map<String, dynamic>> checkAutoLogin() async {
    try {
      final userData = await StorageService.getUserData();
      
      if (userData == null) {
        return {
          'success': false,
          'message': 'No user data found',
          'isLoggedIn': false,
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/auto-login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userData['userId'],
          'email': userData['email'],
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // User is still logged in
        return {
          'success': true,
          'message': responseData['message'],
          'isLoggedIn': true,
          'user': responseData['user'],
        };
      } else {
        // Token is invalid or user is not logged in
        await StorageService.clearLoginData();
        return {
          'success': false,
          'message': responseData['message'] ?? 'Auto-login failed',
          'isLoggedIn': false,
        };
      }
    } catch (e) {
      // Network error or other exception
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'isLoggedIn': false,
      };
    }
  }

  static Future<void> logout() async {
    try {
      final token = await StorageService.getToken();
      
      if (token != null && token.isNotEmpty) {
        // Call logout API to update server-side status
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'token': token,
          }),
        );
      }
    } catch (e) {
      // Even if API call fails, we still clear local data
      print('Logout API call failed: $e');
    } finally {
      // Always clear local storage
      await StorageService.clearLoginData();
    }
  }
}

import '../user/user_model.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
  };

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle case where response is just the user object
    if (json.containsKey('userId')) {
      return AuthResponse(
        token: 'dummy-token',
        user: UserModel.fromJson(json),
      );
    }
    
    // Handle case where response has both token and user
    return AuthResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

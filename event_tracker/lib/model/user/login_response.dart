import '../../utils/import_export.dart';

class LoginResponse {
  final UserModel user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    user: UserModel.fromJson(json['user']),
    token: json['token'],
  );
}

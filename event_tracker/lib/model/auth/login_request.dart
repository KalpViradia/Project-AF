class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    email: json['email'] as String,
    password: json['password'] as String,
  );
}

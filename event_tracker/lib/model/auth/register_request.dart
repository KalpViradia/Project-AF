class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
  };

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
    email: json['email'] as String,
    password: json['password'] as String,
    name: json['name'] as String,
  );
}

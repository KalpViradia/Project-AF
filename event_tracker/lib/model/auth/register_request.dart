class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? countryCode;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.countryCode,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'phone': phone,
    'countryCode': countryCode,
  };

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
    email: json['email'] as String,
    password: json['password'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String?,
    countryCode: json['countryCode'] as String?,
  );
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? countryCode;
  final String? address;
  final String? dateOfBirth;
  final String? gender;
  final String? bio;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.countryCode,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.bio,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'countryCode': countryCode,
    'address': address,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'bio': bio,
    'isActive': isActive ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        userId: (json['userId'] ?? json['UserId'])?.toString() ?? '',
        name: (json['name'] ?? json['Name'])?.toString() ?? '',
        email: (json['email'] ?? json['Email'])?.toString() ?? '',
        phone: (json['phone'] ?? json['Phone'])?.toString(),
        countryCode: (json['countryCode'] ?? json['CountryCode'])?.toString(),
        address: (json['address'] ?? json['Address'])?.toString(),
        dateOfBirth: (json['dateOfBirth'] ?? json['DateOfBirth'])?.toString(),
        gender: (json['gender'] ?? json['Gender'])?.toString(),
        bio: (json['bio'] ?? json['Bio'])?.toString(),
        isActive: (json['isActive'] ?? json['IsActive']) == 1 || (json['isActive'] ?? json['IsActive']) == true,
        createdAt: (json['createdAt'] ?? json['CreatedAt']) != null 
            ? DateTime.parse((json['createdAt'] ?? json['CreatedAt']).toString())
            : DateTime.now(),
        lastLogin: (json['lastLogin'] ?? json['LastLogin']) != null 
            ? DateTime.parse((json['lastLogin'] ?? json['LastLogin']).toString()) 
            : null,
      );
    } catch (e) {
      print('Error parsing UserModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? countryCode,
    String? address,
    String? dateOfBirth,
    String? gender,
    String? bio,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

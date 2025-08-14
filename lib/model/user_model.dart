import '../utils/import_export.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String? gender;
  final String role;
  final String? bio;
  final int emailVerified;
  final int isActive;
  final String? lastLogin;
  final String createdAt;
  final String? updatedAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.dateOfBirth,
    this.avatarUrl,
    this.gender,
    this.role = 'user',
    this.bio,
    this.emailVerified = 0,
    this.isActive = 1,
    this.lastLogin,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    COL_USER_ID: userId,
    COL_USER_NAME: name,
    COL_USER_EMAIL: email,
    COL_USER_PASSWORD: password,
    COL_USER_PHONE: phone,
    COL_USER_DOB: dateOfBirth,
    COL_USER_AVATAR_URL: avatarUrl,
    COL_USER_GENDER: gender,
    COL_USER_ROLE: role,
    COL_USER_BIO: bio,
    COL_USER_EMAIL_VERIFIED: emailVerified,
    COL_USER_IS_ACTIVE: isActive,
    COL_USER_LAST_LOGIN: lastLogin,
    COL_CREATED_AT: createdAt,
    COL_UPDATED_AT: updatedAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    userId: map[COL_USER_ID],
    name: map[COL_USER_NAME],
    email: map[COL_USER_EMAIL],
    password: map[COL_USER_PASSWORD], // Added password
    phone: map[COL_USER_PHONE],
    dateOfBirth: map[COL_USER_DOB],
    avatarUrl: map[COL_USER_AVATAR_URL],
    gender: map[COL_USER_GENDER],
    role: map[COL_USER_ROLE] ?? 'user',
    bio: map[COL_USER_BIO],
    emailVerified: map[COL_USER_EMAIL_VERIFIED] ?? 0,
    isActive: map[COL_USER_IS_ACTIVE] ?? 1,
    lastLogin: map[COL_USER_LAST_LOGIN],
    createdAt: map[COL_CREATED_AT],
    updatedAt: map[COL_UPDATED_AT],
  );

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? password, // Added password
    String? phone,
    String? dateOfBirth,
    String? avatarUrl,
    String? gender,
    String? role,
    String? bio,
    int? emailVerified,
    int? isActive,
    String? lastLogin,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password, // Added password
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

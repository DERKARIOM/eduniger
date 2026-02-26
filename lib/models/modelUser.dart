import 'dart:ffi';
/*
class User {
   int id;
   String? phone;
   String? name;
   String? firstName;
   String? email;
   String? profile;
   int? profession;
   int? role;

  User({
    required this.id,
     this.phone,
     this.name,
     this.firstName,
     this.email,
     this.profile,
     this.profession,
     this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'] ?? '',
      profession: json['profession'] ?? 0,
      role: json['role'] ?? 0,

    );
  }
}

class AuthData {
  final User user;
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  AuthData({
    required this.user,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user']),
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
    );
  }
}

class AuthResponse {
  final String status;
  final int code;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? 'error',
      code: json['code'] ?? 400,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success' && code == 200;
}
*/
// ─── modelUser.dart ───────────────────────────────────────────────
class User {
  int id;
  String? phone;
  String? name;
  String? firstName;
  String? email;
  String? profile;
  String? profession; // ← String, pas int
  int? role;

  User({
    required this.id,
    this.phone,
    this.name,
    this.firstName,
    this.email,
    this.profile,
    this.profession,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
      profession: json['profession']?.toString() ?? '',
      role: json['role'] is int ? json['role'] : int.tryParse(json['role']?.toString() ?? '0'),
    );
  }
}

class AuthData {
  final User user;
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  AuthData({
    required this.user,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user']),
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      expiresIn: json['expires_in'] is int ? json['expires_in'] : int.tryParse(json['expires_in']?.toString() ?? '3600') ?? 3600,
    );
  }
}

class AuthResponse {
  final String status;
  final int code;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status']?.toString() ?? 'error',
      code: json['code'] is int ? json['code'] : int.tryParse(json['code']?.toString() ?? '400') ?? 400,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success' && code == 200;
}
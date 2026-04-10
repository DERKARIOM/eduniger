class UserDto {
  int id;
  String? phone;
  String? name;
  String? firstName;
  String? email;
  String? profile;
  String? profession; // ← String, pas int
  int? role;
  String? accessToken;


  UserDto({
    required this.id,
    this.phone,
    this.name,
    this.firstName,
    this.email,
    this.profile,
    this.profession,
    this.role,
    this.accessToken,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? 0,
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
      profession: json['profession']?.toString() ?? '',
      role: json['role'] is int ? json['role'] : int.tryParse(json['role']?.toString() ?? '0'),
      accessToken: json['accessToken']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson(UserDto userdto) {
    return {
      'id': userdto.id,
      'phone': userdto.phone,
      'name': userdto.name,
      'firstName': userdto.firstName,
      'email': userdto.email,
      'profile': userdto.profile,
      'profession': userdto.profession,
      'role': userdto.role,
      'accessToken': userdto.accessToken,
    };
  }

}
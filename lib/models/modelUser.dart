// Modèle User
class User {
  final String name;
  final String firstName;
  final String? email;
  final String? profile;
  final String ?profession;
  final bool isAdmin;

  User({
    required this.name,
    required this.firstName,
    this.email,
    this.profile,
    this.profession,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'] ?? '',
      profession: json['profession'] ?? '',
      isAdmin: json['isAdmin'] == 1 || json['isAdmin'] == '1' || json['isAdmin'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'firstName': firstName,
      'email': email,
      'profile': profile,
      'profession': profession,
      'isAdmin': isAdmin,
    };
  }
}

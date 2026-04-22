import '../../utilisateurs/models/user_model.dart';

class Author {
  int id;
  String phone;
  String  name;
  String firstName;
  String email;
  String profile;
  String profession;
   int     level;
   String? whatsapp;


  Author({
    required this.id,
    required this.phone,
    required this.name,
    required this.firstName,
    required  this.email,
    required this.profile,
    required this.profession,
    required this.level,
    required this.whatsapp,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['idAuthor'] is int
          ? json['idAuthor']
          : int.tryParse(json['idAuthor']?.toString() ?? '0') ?? 0,
      phone      : json['call']?.toString()        ?? '',
      name       : json['name']?.toString()        ?? '',
      firstName  : json['firstName']?.toString()   ?? '',
      email      : json['email']?.toString()        ?? '',
      profile    : json['profile']?.toString()     ?? '',
      profession : json['profession']?.toString()  ?? '',
      level      : json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '0') ?? 0,
      whatsapp   : json['whatsapp']?.toString()    ?? '',
    );
  }
}

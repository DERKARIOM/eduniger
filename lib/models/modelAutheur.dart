import 'modelUser.dart';
import 'package:flutter/material.dart';
/*
class Author extends User {
  int level;
  String? whatsapp;
  Author({
    this.whatsapp,
    required super.id,
    required super.phone,
    required super.name,
    required super.firstName,
    required super.email,
    required super.profile,
    required this.level});
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ??'',
      phone: json['phone'] ??'',
      name: json['name'] ??'',
      firstName: json['firstName'] ??'',
      email: json['email'] ??'',
      profile: json['profile'] ??'',
      level: json['level'] is int ? json['level'] : int.tryParse(json['level'].toString()) ?? 0,
      whatsapp: json['whatsapp'] ??'',
    );
  }
}
*/
// ─── modelAuthor.dart ─────────────────────────────────────────────
import 'modelUser.dart';

class Author extends User {
  int level;
  String? whatsapp;

  Author({
    this.whatsapp,
    required super.id,
    super.phone,       // = call dans le JSON
    super.name,
    super.firstName,
    super.email,
    super.profile,
    super.profession,  // String
    required this.level,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      // ← clé "idAuthor" et non "id"
      id: json['idAuthor'] is int
          ? json['idAuthor']
          : int.tryParse(json['idAuthor']?.toString() ?? '0') ?? 0,

      // ← clé "call" et non "phone"
      phone: json['call']?.toString() ?? '',

      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',

      // ← "profession" est une String ici ("AUTEUR EDUNIGER")
      profession: json['profession']?.toString() ?? '',

      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '0') ?? 0,

      whatsapp: json['whatsapp']?.toString() ?? '',
    );
  }
}
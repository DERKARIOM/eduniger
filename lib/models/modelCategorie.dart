import 'package:flutter/material.dart';
class MCategorie {
  String? id;
  String? cover;
  String? name;
  String ?description;
  bool ?isAdhere;
  String ?banner;
  String? author;
  String? bookNumber;
  String? admin;

  // Ceci est un constructeur Dart qui initialise directement les champs.
  // On utilise `this.` pour différencier les paramètres des champs de la classe.
  MCategorie({
     this.id,
     this.cover,
     this.name,
     this.description,
     this.isAdhere,
     this.banner,
     this.author,
     this.bookNumber,
     this.admin,
  });
factory MCategorie.fromJson(Map<String, dynamic> json) {
  return MCategorie(
    id: json['id'],
    cover: json['cover'],
    name: json['name'],
      description: json['description'],
      isAdhere: json['is_adhere'],
      banner: json['banner'],
      author: json['author'],
      bookNumber: json['book_number'],
      admin: json['admin'],);



}
// En Dart, les getters et setters sont généralement implicites.
// Vous pouvez accéder directement aux propriétés (ex: maStructure.name).
// Il n'est pas nécessaire de créer des méthodes comme getName() ou setName().
}

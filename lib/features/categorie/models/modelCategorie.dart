import 'package:flutter/material.dart';
class MCategorie {
  int? id;
  String? cover;
  String? name;
  int? number_inscri;

  // Ceci est un constructeur Dart qui initialise directement les champs.
  // On utilise `this.` pour différencier les paramètres des champs de la classe.
  MCategorie({
     this.id,
     this.cover,
     this.name,
     this.number_inscri,
  });
factory MCategorie.fromJson(Map<String, dynamic> json) {
  return MCategorie(
    id: json['idCategory']as int?,
    cover: json['blanket'],
    name: json['title'],
      number_inscri: json['numberSubscribe'] as int?,
  );



}
// En Dart, les getters et setters sont généralement implicites.
// Vous pouvez accéder directement aux propriétés (ex: maStructure.name).
// Il n'est pas nécessaire de créer des méthodes comme getName() ou setName().
}

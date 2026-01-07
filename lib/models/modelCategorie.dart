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

// En Dart, les getters et setters sont généralement implicites.
// Vous pouvez accéder directement aux propriétés (ex: maStructure.name).
// Il n'est pas nécessaire de créer des méthodes comme getName() ou setName().
}

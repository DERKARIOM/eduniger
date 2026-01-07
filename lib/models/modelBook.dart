import 'dart:core';
import 'dart:ffi';

import 'package:flutter/material.dart';

class Book {
  String id;
  String title;
  String? cover;
  String structure;
  String category;
  String? author;
  String? description;
  bool? isaudio;
  bool? isphisique;
  bool? ispdf;
  String? profileAuthor;

  // En Dart, on utilise un seul constructeur avec des paramètres nommés optionnels.
  // 'id' est requis, tandis que les autres sont optionnels.
  // Cela remplace les multiples constructeurs de votre code original.
  Book({
    required this.id,
    required this.title,
    this.cover,
    required this.structure,
    required this.category,
    this.author,
    this.description,
    this.isaudio,
    this.isphisique,
    this.ispdf,
    this.profileAuthor,
  });

}

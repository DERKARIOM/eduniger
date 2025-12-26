import 'dart:core';

import 'package:flutter/material.dart';

class Book {
  String id;
  String? title;
  String? cover;
  String? category;
  String? author;
  String? description;
  String? coverCategory;
  String? profileAuthor;

  // En Dart, on utilise un seul constructeur avec des paramètres nommés optionnels.
  // 'id' est requis, tandis que les autres sont optionnels.
  // Cela remplace les multiples constructeurs de votre code original.
  Book({
    required this.id,
    this.title,
    this.cover,
    this.category,
    this.author,
    this.description,
    this.coverCategory,
    this.profileAuthor,
  });

}

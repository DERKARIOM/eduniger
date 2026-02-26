import 'dart:core';
import 'dart:ffi';

import 'package:flutter/material.dart';
/*
class Book {
  String? idBock;
  String? couvertures;
  String? titleBock;
  String? idcategory;
  String? titlecategory;
  bool? isphisique;
  String? electronic;
  bool? isaudio;
  int? numberLike;
  int? numberViw;
  String? nomStructure;
  String? lastDate;

  // En Dart, on utilise un seul constructeur avec des paramètres nommés optionnels.
  // 'id' est requis, tandis que les autres sont optionnels.
  // Cela remplace les multiples constructeurs de votre code original.
  Book({
    required this.idBock,
     this.couvertures,
     this.titleBock,
     this.idcategory,
     this.titlecategory,
     this.isphisique,
     this.electronic,
     this.isaudio,
     this.numberLike,
     this.numberViw,
     this.nomStructure,
     this.lastDate,


  });
  // Dans lib/models/modelBook.dart
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      idBock: json['idBook']?.toString() ?? '', // Sécurité : conversion en String
      couvertures: json['blanket']?.toString() ?? '',
      titleBock: json['bookTitle']?.toString() ?? 'Titre inconnu',
      titlecategory: json['categoryTitle']?.toString() ?? '',
      // Pour les nombres venant de PHP (souvent envoyés en String ou int)
      numberLike: int.tryParse(json['numberLike']?.toString() ?? '0') ?? 0,
      numberViw: int.tryParse(json['numberView']?.toString() ?? '0') ?? 0,
      nomStructure: json['nameStruct']?.toString() ?? '',
    );
  }
  /*
factory Book.fromJson(Map<String, dynamic> json) {
  return Book(
    idBock: json['id'],
    couvertures: json['couvertures'],
    titleBock: json['title'],
      idcategory: json['idcategory'],
      titlecategory: json['titlecategory'],
      isphisique: json['isphisique'],
      electronic: json['electronic'],
      isaudio: json['isaudio'],
      numberLike: json['numberLike'],
      numberViw: json['numberViw'],
      nomStructure: json['nomStructure'],
      lastDate: json['lastDate'],
  );



}
*/
}
*/
// ─── modelBook.dart ───────────────────────────────────────────────
class Book {
  final String? idBook;
  final String? blanket;
  final String? bookTitle;
  final int? idCategories;   // ← int
  final String? categoryTitle;
  final bool? isPhysic;      // ← isPhysic (pas isphisique)
  final String? electronic;  // nullable dans le JSON
  final bool? isAudio;
  final int? numberLike;
  final int? numberView;     // ← numberView (pas numberViw)
  final String? nameStruct;
  final String? lastDate;

  Book({
    this.idBook,
    this.blanket,
    this.bookTitle,
    this.idCategories,
    this.categoryTitle,
    this.isPhysic,
    this.electronic,
    this.isAudio,
    this.numberLike,
    this.numberView,
    this.nameStruct,
    this.lastDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      idBook: json['idBook']?.toString(),

      blanket: json['blanket']?.toString(),

      bookTitle: json['bookTitle']?.toString() ?? 'Titre inconnu',

      idCategories: json['idCategories'] is int
          ? json['idCategories']
          : int.tryParse(json['idCategories']?.toString() ?? ''),

      categoryTitle: json['categoryTitle']?.toString(),

      // 0 ou 1 dans le JSON
      isPhysic: _intToBool(json['isPhysic']),

      electronic: json['electronic']?.toString(), // peut être null

      isAudio: _intToBool(json['isAudio']),

      numberLike: json['numberLike'] is int
          ? json['numberLike']
          : int.tryParse(json['numberLike']?.toString() ?? '0') ?? 0,

      numberView: json['numberView'] is int
          ? json['numberView']
          : int.tryParse(json['numberView']?.toString() ?? '0') ?? 0,

      nameStruct: json['nameStruct']?.toString(),

      lastDate: json['lastDate']?.toString(),
    );
  }
}

bool? _intToBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  return null;
}
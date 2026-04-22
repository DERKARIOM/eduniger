import 'package:flutter/material.dart';

import '../dto/book_dto.dart';

class LivresModel {
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
  final String? dStructures;
  final String? nameStruct;
  final String? lastDate;

  LivresModel({
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
    this.dStructures,
    this.nameStruct,
    this.lastDate,
  });

  factory LivresModel.fromJson(Map<String, dynamic> json) {
    return LivresModel(
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
      dStructures: json['idStructures']?.toString(),

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
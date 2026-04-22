import 'package:flutter/material.dart';

import '../dto/book_dto.dart';
/*
class BookModel {
   String? _id;
   String? _couverture;
   String? _Titre;
   int? _idantifiant_Categorie;
   String? _titre_categorie;
   bool? _est_pysique;
   String? _est_electronique;
   bool? _est_audio;
   int? _nombre_jaime;
   int? _nombre_no_jaime;
   int? _est_abonne;
   int? _nombre_vue;
   String? _nom_structure;
   String? _chement_fichier;
   String? _derniere_date;

   BookModel({
     required String id,
     required String couverture,
     required String Titre,
     required int idantifiant_Categorie,
     required String titre_categorie,
     required bool est_pysique,
     required String est_electronique,
     required bool est_audio,
     required int nombre_jaime,
     required int nombre_vue,
     required String nom_structure,
     required String derniere_date,
}):_id=id,
     _couverture=couverture,
     _Titre=Titre,
     _idantifiant_Categorie=idantifiant_Categorie,
     _titre_categorie=titre_categorie,
     _est_pysique=est_pysique,
     _est_electronique=est_electronique,
     _est_audio=est_audio,
     _nombre_jaime=nombre_jaime,
    _nombre_vue=nombre_vue,
     _nom_structure=nom_structure,
     _derniere_date=derniere_date{
     }

   void ajouter_jaime(int nombre_jaime) {
     _nombre_jaime = nombre_jaime;
   }
void ajouter_vue(int nombre_vue) {
_nombre_vue = nombre_vue;
}

String get id => _id!;
String get couverture => _couverture!;
String get Titre => _Titre!;
int get idantifiant_Categorie => _idantifiant_Categorie!;
String get titre_categorie => _titre_categorie!;
bool get est_pysique => _est_pysique!;
String get est_electronique => _est_electronique!;
bool get est_audio => _est_audio!;
int get nombre_jaime => _nombre_jaime!;
int get nombre_no_jaime => _nombre_no_jaime!;
int get est_abonne => _est_abonne!;
int get nombre_vue => _nombre_vue!;
String get nom_structure => _nom_structure!;
String get chement_fichier => _chement_fichier!;
String get derniere_date => _derniere_date!;



}
*/
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
  final String? idStruct;
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
    this.idStruct,
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
      idStruct: json['idStruct']?.toString(),

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
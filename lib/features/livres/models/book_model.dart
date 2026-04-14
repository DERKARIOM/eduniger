import 'package:flutter/material.dart';
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
   int? _nombre_vue;
   String? _nom_structure;
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
int get nombre_vue => _nombre_vue!;
String get nom_structure => _nom_structure!;
String get derniere_date => _derniere_date!;



}
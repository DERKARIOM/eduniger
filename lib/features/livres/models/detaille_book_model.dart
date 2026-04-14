class DetailleBookModel {
   String? _id;
   String? _couverture;
   String? _titre;
   //String? authorName;
   String? _description;
   String? _titre_categorie;
   bool? _est_pysique;
   String? _est_electronique;
   bool? _est_audio;
   int? _nombre_jaime;
   int? _nombre_no_jaime;
   int? _nombre_subscribe;
   int? _nombre_vue;
   String? _image_categorie;

   int? _id_auteur;
   String? _nom_auteur;
   String? _prenom_auteur;
   String? _profile_auteur;
   int? _disponible;
   String? _profession;
   String? _telephone;
   String? _email;
   String? _whatsapp;
   dynamic? _taille;
   dynamic? _nombre_page;
   DetailleBookModel({
      required String id,
      required String couverture,
      required String titre,
      required String description,
      required String titre_categorie,
      required bool est_pysique,
      required String est_electronique,
      required bool est_audio,
      required int nombre_jaime,
      required int nombre_no_jaime,
      required int nombre_subscribe,
      required int nombre_vue,
      required String image_categorie,
      required int id_auteur,
      required String nom_auteur,
      required String prenom_auteur,
      required String profile_auteur,
      required int disponible,
      required String profession,
      required String telephone,
      required String email,
      required String whatsapp,
      required dynamic taille,
      required dynamic nombre_page,
}): _id=id,
   _couverture=couverture,
    _titre=titre,
    _description=description,
   _titre_categorie=titre_categorie,
    _est_pysique=est_pysique,
    _est_electronique=est_electronique,
_est_audio=est_audio,
    _nombre_jaime=nombre_jaime,
_nombre_no_jaime=nombre_no_jaime,
    _nombre_subscribe=nombre_subscribe,
    _nombre_vue=nombre_vue,
    _image_categorie=image_categorie,
    _id_auteur=id_auteur,
    _nom_auteur=nom_auteur,
_prenom_auteur=prenom_auteur,
    _profile_auteur=profile_auteur,
_disponible=disponible,
    _profession=profession,
    _telephone=telephone,
    _email=email,
    _whatsapp=whatsapp,
    _taille=taille,
    _nombre_page=nombre_page{

   }
   void ajouter_jaime(int nombre_jaime) {
     _nombre_jaime = nombre_jaime;
   }
   void ajouter_no_jaime(int nombre_no_jaime) {
     _nombre_no_jaime = nombre_no_jaime;
   }
   void ajouter_subscribe(int nombre_subscribe) {
     _nombre_subscribe = nombre_subscribe;
   }
   void ajouter_vue(int nombre_vue) {
     _nombre_vue = nombre_vue;
   }

String get id => _id!;
String get couverture => _couverture!;
String get titre => _titre!;
String get description => _description!;
String get titre_categorie => _titre_categorie!;
bool get est_pysique => _est_pysique!;
String get est_electronique => _est_electronique!;
bool get est_audio => _est_audio!;
int get nombre_jaime => _nombre_jaime!;
int get nombre_no_jaime => _nombre_no_jaime!;
int get nombre_subscribe => _nombre_subscribe!;
int get nombre_vue => _nombre_vue!;
String get image_categorie => _image_categorie!;
int get id_auteur => _id_auteur!;
String get nom_auteur => _nom_auteur!;
String get prenom_auteur => _prenom_auteur!;
String get profile_auteur => _profile_auteur!;
int get disponible => _disponible!;
String get profession => _profession!;
String get telephone => _telephone!;
String get email => _email!;
String get whatsapp => _whatsapp!;
dynamic get taille => _taille!;
dynamic get nombre_page => _nombre_page!;


}
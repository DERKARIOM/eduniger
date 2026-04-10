import 'dart:core';
import 'package:flutter/material.dart';
class UserModel {
final  int _idantifiant;
String _nom;
String _prenom;
String _numero;
String _mail;
String _mot_de_passe;
String _profession;
int?  _role;
String?  _accessToken;

UserModel({
  required int idantifiant,
  required String nom,
  required String prenom,
  required String numero,
  required String mail,
  required String mot_de_passe,
   required String profession,
    int? role,
   String? accessToken,
}): _idantifiant=idantifiant,
_nom=nom,
_prenom=prenom,
_numero=numero,
_mail=mail,
_mot_de_passe=mot_de_passe,
_profession=profession,
      _role=role,
_accessToken=accessToken{
  //Validation des données
_validationNom(_nom);
_validationPrenom(_prenom);
_validationNumero(_numero);
_validationMail(_mail);
_validationMot_de_passe(_mot_de_passe);
_validationProfession(_profession);

}
_validationNom(String nom) {
  if (nom.isEmpty) {
    throw Exception("Le nom ne doit pas être vide");
  }
}
_validationPrenom(String prenom) {
if (prenom.isEmpty) {
throw Exception("Le prénom ne doit pas être vide");
}
}
_validationNumero(String numero) {
  if (numero.isEmpty) {
    throw Exception("Le numéro ne doit pas être vide");
  }
}
_validationMail(String mail) {
  if (mail.isEmpty) {
    throw Exception("Le mail ne doit pas être vide");
  }
  if (!mail.contains("@")) {
    throw Exception("Ce mail ne pas valide");
  }
  if (!mail.contains(".")) {
    throw Exception("Ce mail ne pas valide");
  }


}
_validationMot_de_passe(String mot_de_passe) {
  if (mot_de_passe.isEmpty) {
    throw Exception("Le mot de passe ne doit pas être vide");
  }

}
_validationProfession(String profession) {
  if (profession.isEmpty) {
    throw Exception("La profession ne doit pas être vide");
  }
}
//les methode de metier
void verifier_mot_de_passe(String mot_de_passe, String mot_de_passe_confirmer) {
  _validationMot_de_passe(mot_de_passe);
  _validationMot_de_passe(mot_de_passe_confirmer);
  if (mot_de_passe != mot_de_passe_confirmer) {
    throw Exception("Les mots de passe ne correspondent pas");
  }
}
void _valide_change_password(String numero,String email, String mot_de_passe,String mot_de_passe_confirmer){
  if (numero.isEmpty&&email.isEmpty&&mot_de_passe.isEmpty&&mot_de_passe_confirmer.isEmpty)
  {
    throw Exception("Veuillez remplir tous les champs");

  }
}
  void changer_mot_de_passe(String numero,String email, String mot_de_passe,String mot_de_passe_confirmer) {
   _valide_change_password(numero, email, mot_de_passe, mot_de_passe_confirmer);
    _validationNumero(numero);
    _validationMail(email);
    verifier_mot_de_passe(mot_de_passe, mot_de_passe_confirmer);
    _mot_de_passe = mot_de_passe;

  }
  void changer_profil(String numero,String email, String nom,String prenom,String profession) {
    _validationNumero(numero);
    _validationMail(email);
    _validationNom(nom);
    _validationPrenom(prenom);
    _validationProfession(profession);
    _nom = nom;
    _prenom = prenom;
    _profession = profession;
    _mail = email;
  }
  void _valider_compte(String numero,String email, String nom,String prenom,String mot_de_passe,String mot_de_passe_confirmer,String profession){
  if (numero.isEmpty&&email.isEmpty&&nom.isEmpty&&prenom.isEmpty&&mot_de_passe.isEmpty&&mot_de_passe_confirmer.isEmpty&&profession.isEmpty)
    {
      throw Exception("Veuillez remplir tous les champs");

    }
  }
  void creer_compte(String numero,String email, String nom,String prenom,String mot_de_passe,String mot_de_passe_confirmer,String profession) {
    _valider_compte(numero, email, nom, prenom, mot_de_passe, mot_de_passe_confirmer, profession);
  _validationNumero(numero);
_validationMail(email);
_validationNom(nom);
_validationPrenom(prenom);
verifier_mot_de_passe(mot_de_passe, mot_de_passe_confirmer);
_validationProfession(profession);
_nom = nom;
_prenom = prenom;
_profession = profession;
_mail = email;
_mot_de_passe = mot_de_passe;
_numero = numero;

}
void _valider_login(String numero,String mot_de_passe) {
  if (numero.isEmpty&&mot_de_passe.isEmpty)
  {
    throw Exception("Veuillez remplir tous les champs");
  }

}
void se_connecter(String numero,String mot_de_passe) {
  _valider_login(numero, mot_de_passe);
_validationNumero(numero);
_validationMot_de_passe(mot_de_passe);
_numero = numero;
_mot_de_passe = mot_de_passe;
}
void supprimer_compte(String numero,String mot_de_passe) {
  _validationNumero(numero);
  _validationMot_de_passe(mot_de_passe);
}



int  get idantifiant => _idantifiant;
 String get nom => _nom;
String get prenom => _prenom;
String get numero => _numero;
String get mail => _mail;
String get mot_de_passe => _mot_de_passe;
String get profession => _profession;
int get role => _role!;
String? get accessToken => _accessToken;





}



import 'modelUser.dart';

class Author extends User {
  // On utilise un seul type pour `profile`. `String` est généralement plus flexible
  // pour contenir un chemin d'accès (URL) ou une référence à un asset.
  String? profile;
  String? profession;
  String? call;
  String? email;
  String? whatsapp;

  // Constructeur principal avec des paramètres nommés pour plus de clarté.
  Author({
    // Paramètres de la classe parente (User)
    required String name,
    required String firstName,
    required bool isAdmin,


    // Paramètres de la classe Author
    this.profile,
    this.profession,
    this.call,
    this.email,
    this.whatsapp,
  }) : super(name: name, firstName: firstName, isAdmin: isAdmin);

  factory Author.fromProfile({
    required String name,
    required String profile,
    required String firstName,
    required bool isAdmin,
  }) {
    return Author(
      name: name,
      profile: profile,
      firstName: firstName,
      isAdmin: isAdmin,

    );
  }

// Getters et Setters ne sont pas nécessaires en Dart pour un accès direct.
// Vous pouvez faire :
// var myAuthor = Author(name: 'Sembene');
// myAuthor.profession = 'Cinéaste'; // set
// print(myAuthor.profession); // get
}

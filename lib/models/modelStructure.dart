class Structure {
  String id;
  String cover;
  String name;
  String description;
  bool isAdhere;
  String banner;
  String author;
  String adhererNumber;
  String bookNumber;
  String admin;

  // Ceci est un constructeur Dart qui initialise directement les champs.
  // On utilise `this.` pour différencier les paramètres des champs de la classe.
  Structure({
    required this.id,
    required this.cover,
    required this.name,
    required this.description,
    required this.isAdhere,
    required this.banner,
    required this.author,
    required this.adhererNumber,
    required this.bookNumber,
    required this.admin,
  });

// En Dart, les getters et setters sont généralement implicites.
// Vous pouvez accéder directement aux propriétés (ex: maStructure.name).
// Il n'est pas nécessaire de créer des méthodes comme getName() ou setName().
}

/*
class Structure {
  final String? id;
  final String? name;
  final String? logo;
  final String? banner;
  final String? author;
  final String? adhererNumber;
  final String? bookNumber;
  final String? description;
  final bool? isAdmin;
  final bool isAdhere;

  // Le constructeur utilise maintenant des paramètres nommés pour plus de clarté
  Structure({
    this.id,
    this.name,
    this.logo,
    this.banner,
    this.author,
    this.adhererNumber,
    this.bookNumber,
    this.description,
    this.isAdmin,
    required this.isAdhere,
  });

  // La factory 'fromJson' a été corrigée pour correspondre aux clés JSON
  // et aux noms des champs de la classe.
  factory Structure.fromJson(Map<String, dynamic> json) {
    return Structure(
      // Assure une conversion sécurisée si l'API envoie l'ID comme une chaîne de caractères
      id: json['id'] as String ? ,

      // La clé JSON pour 'name' est 'nameStruct' d'après vos logs précédents
      name: json['nameStruct'] as String?,

      logo: json['logo'] as String?,
      banner: json['banner'] as String?,
      author: json['author'] as String?,

      // Correction des clés JSON avec des underscores
      adhererNumber: json['adhererNumber'] as String?,
      bookNumber: json['bookNumber'] as String?,

      description: json['description'] as String?,

      // Assure une conversion sécurisée si l'API envoie 0/1 au lieu de true/false
      isAdmin: _parseBool(json['isAdmin']),
      isAdhere: _parseBool(json['isAdhere']) ?? false,
    );
  }
}

// Fonction utilitaire pour convertir de manière fiable une valeur en booléen
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return null;
}
*/
// ─── modelStructure.dart ──────────────────────────────────────────
class Structure {
  final int? id;           // ← int, pas String
  final String? name;
  final String? logo;
  final String? banner;
  final String? author;
  final int? adhererNumber; // ← int, pas String
  final int? bookNumber;    // ← int, pas String
  final String? description;
  final bool? isAdmin;
  final bool isAdhere;      // ← géré manuellement, absent du JSON "recommandé"

  Structure({
    this.id,
    this.name,
    this.logo,
    this.banner,
    this.author,
    this.adhererNumber,
    this.bookNumber,
    this.description,
    this.isAdmin,
    required this.isAdhere,
  });

  factory Structure.fromJson(Map<String, dynamic> json, {bool isAdhere = false}) {
    return Structure(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),

      name: json['nameStruct']?.toString(),
      logo: json['logo']?.toString(),
      banner: json['banner']?.toString(),
      author: json['author']?.toString(),

      adhererNumber: json['adhererNumber'] is int
          ? json['adhererNumber']
          : int.tryParse(json['adhererNumber']?.toString() ?? ''),

      bookNumber: json['bookNumber'] is int
          ? json['bookNumber']
          : int.tryParse(json['bookNumber']?.toString() ?? ''),

      description: json['description']?.toString(),

      // présent seulement dans les structures adhérées (0 ou 1)
      isAdmin: _parseBool(json['isAdmin']),

      // passé en paramètre selon la liste d'où vient la structure
      isAdhere: isAdhere,
    );
  }
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return null;
}
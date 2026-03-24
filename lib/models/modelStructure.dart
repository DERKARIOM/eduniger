
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
      id: json['id']is int
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
  Structure copyWith({bool? isAdhere}) {
    return Structure(
      id: this.id,
      name: this.name,
      logo: this.logo,
      banner: this.banner,
      author: this.author,
      adhererNumber: this.adhererNumber,
      bookNumber: this.bookNumber,
      description: this.description,
      isAdmin: this.isAdmin,
      isAdhere: isAdhere ?? this.isAdhere, // Remplace si fourni, sinon garde l'actuel
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
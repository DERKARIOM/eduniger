class Structure {
  final int?    id;
  final String? name;
  final String? logo;
  final String? banner;
  final String? author;
  final int?    adhererNumber;
  final int?    bookNumber;
  final String? description;
  final bool?   isAdmin;
  final bool    isAdhere;

  const Structure({
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
      name        : json['nameStruct']?.toString(),
      logo        : json['logo']?.toString(),
      banner      : json['banner']?.toString(),
      author      : json['author']?.toString(),
      adhererNumber: json['adhererNumber'] is int
          ? json['adhererNumber']
          : int.tryParse(json['adhererNumber']?.toString() ?? ''),
      bookNumber  : json['bookNumber'] is int
          ? json['bookNumber']
          : int.tryParse(json['bookNumber']?.toString() ?? ''),
      description : json['description']?.toString(),
      isAdmin     : _parseBool(json['isAdmin']),
      isAdhere    : isAdhere,
    );
  }

  // ← copyWith complet (tous les champs, pas seulement isAdhere)
  Structure copyWith({
    int?    id,
    String? name,
    String? logo,
    String? banner,
    String? author,
    int?    adhererNumber,
    int?    bookNumber,
    String? description,
    bool?   isAdmin,
    bool?   isAdhere,
  }) {
    return Structure(
      id            : id            ?? this.id,
      name          : name          ?? this.name,
      logo          : logo          ?? this.logo,
      banner        : banner        ?? this.banner,
      author        : author        ?? this.author,
      adhererNumber : adhererNumber ?? this.adhererNumber,
      bookNumber    : bookNumber    ?? this.bookNumber,
      description   : description   ?? this.description,
      isAdmin       : isAdmin       ?? this.isAdmin,
      isAdhere      : isAdhere      ?? this.isAdhere,
    );
  }
}

bool? _parseBool(dynamic value) {
  if (value == null)   return null;
  if (value is bool)   return value;
  if (value is int)    return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return null;
}
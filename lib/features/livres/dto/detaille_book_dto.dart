class BookDetailDto {
  final String? idBook;
  final String? bookBlanket;
  final String? bookTitle;
  final String? authorName;
  final String? description;
  final String? categoryTitle;
  final bool? isPhysic;
  final String? electronic;
  final bool? isAudio;
  final int? numberLike;
  final int? numberNoLike;
  final int? numberSubscribe;
  final int? numberView;
  final String? categoryBlanket;
  final String? idStructure;
  final int? idAuthor;
  final String? name;
  final String? firstName;
  final String? profile;
  final int? available;
  final String? profession;
  final String? call;
  final String? email;
  final String? whatsapp;
  final dynamic? size;
  final dynamic? nbrPage;

  BookDetailDto({
    this.idBook,
    this.bookBlanket,
    this.bookTitle,
    this.authorName,
    this.description,
    this.categoryTitle,
    this.isPhysic,
    this.electronic,
    this.isAudio,
    this.numberLike,
    this.numberNoLike,
    this.numberSubscribe,
    this.numberView,
    this.categoryBlanket,
    this.idStructure,
    this.idAuthor,
    this.name,
    this.firstName,
    this.profile,
    this.available,
    this.profession,
    this.call,
    this.email,
    this.whatsapp,
    this.size,
    this.nbrPage,
  });

  factory BookDetailDto.fromJson(Map<dynamic, dynamic> json) {
    // Fonction utilitaire locale pour convertir les données de l'API (0/1 ou "0"/"1") en booléen
    bool? toBool(dynamic value) {
      if (value == null) return null;
      return value == 1 || value == "1" || value == true || value == "true";
    }

    // Fonction utilitaire pour forcer la conversion en int (au cas où l'API renvoie du texte)
    int? toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return BookDetailDto(
      idBook: json['idBook']?.toString() ?? json['0']?.toString(),
      bookBlanket: json['bookBlanket']?.toString() ?? json['1']?.toString(),
      bookTitle: json['bookTitle']?.toString() ?? json['2']?.toString(),
      authorName: json['authorName']?.toString() ?? json['3']?.toString(),
      description: json['description']?.toString() ?? json['4']?.toString(),
      categoryTitle: json['categoryTitle']?.toString() ?? json['5']?.toString(),

      // Correction des types booléens
      isPhysic: toBool(json['isPhysic'] ?? json['6']),
      electronic: json['electronic'] ?? json['7']?.toString(),
      isAudio: toBool(json['isAudio'] ?? json['8']),

      // Sécurisation des types entiers
      numberLike: toInt(json['numberLike'] ?? json['9']),
      numberNoLike: toInt(json['numberNoLike'] ?? json['10']),
      numberSubscribe: toInt(json['numberSubscribe'] ?? json['11']),
      numberView: toInt(json['numberView'] ?? json['12']),

      categoryBlanket: json['categoryBlanket']?.toString() ?? json['13']?.toString(),
      idAuthor: toInt(json['idAuthor'] ?? json['14']),
      name: json['name']?.toString() ?? json['15']?.toString(),
      firstName: json['firstName']?.toString() ?? json['16']?.toString(),
      profile: json['profile']?.toString() ?? json['17']?.toString(),
      available: toInt(json['available'] ?? json['18']),
      profession: json['profession']?.toString() ?? json['19']?.toString(),
      call: json['call']?.toString() ?? json['20']?.toString(),
      email: json['email']?.toString() ?? json['21']?.toString(),
      whatsapp: json['whatsapp']?.toString() ?? json['22']?.toString(),

      size: json['size'] ?? json['23'],
      nbrPage: json['nbrPage'] ?? json['24'],
      idStructure: json ['idStructures'] ?? json['25']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idBook': idBook,
      'bookBlanket': bookBlanket,
      'bookTitle': bookTitle,
      'authorName': authorName,
      'description': description,
      'categoryTitle': categoryTitle,
      'isPhysic': isPhysic,
      'electronic': electronic,
      'isAudio': isAudio,
      'numberLike': numberLike,
      'numberNoLike': numberNoLike,
      'numberSubscribe': numberSubscribe,
      'numberView': numberView,
      'categoryBlanket': categoryBlanket,
      'idAuthor': idAuthor,
      'name': name,
      'firstName': firstName,
      'profile': profile,
      'available': available,
      'profession': profession,
      'call': call,
      'email': email,
      'whatsapp': whatsapp,
      'size': size,
      'nbrPage': nbrPage,
    };
  }
}
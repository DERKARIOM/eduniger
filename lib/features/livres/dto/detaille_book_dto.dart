class BookDetailDto {
  final String? idBook;
  final String? bookBlanket;
  final String? bookTitle;
  final String? authorName;
  final String? description;
  final String? categoryTitle;
  final bool? isPhysic;
  final bool? electronic;
  final bool? isAudio;
  final int? numberLike;
  final int? numberNoLike;
  final int? numberSubscribe;
  final int? numberView;
  final String? categoryBlanket;
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

  factory BookDetailDto.fromJson(Map<String, dynamic> json) {
    return BookDetailDto(
      idBook: json['idBook'] ?? json['0'] ?? '',
      bookBlanket: json['bookBlanket'] ?? json['1'] ?? '',
      bookTitle: json['bookTitle'] ?? json['2'] ?? '',
      authorName: json['authorName'] ?? json['3'] ?? '',
      description: json['description'] ?? json['4'] ?? '',
      categoryTitle: json['categoryTitle'] ?? json['5'] ?? '',
      isPhysic: json['isPhysic'] ?? json['6'] ,
      electronic: json['electronic'] ?? json['7'],
      isAudio: json['isAudio'] ?? json['8'],
      numberLike: json['numberLike'] ?? json['9'],
      numberNoLike: json['numberNoLike'] ?? json['10'],
      numberSubscribe: json['numberSubscribe'] ?? json['11'],
      numberView: json['numberView'] ?? json['12'],
      categoryBlanket: json['categoryBlanket'] ?? json['13'] ?? '',
      idAuthor: json['idAuthor'] ?? json['14'],
      name: json['name'] ?? json['15'] ?? '',
      firstName: json['firstName'] ?? json['16'] ?? '',
      profile: json['profile'] ?? json['17'] ?? '',
      available: json['available'] ?? json['18'],
      profession: json['profession'] ?? json['19'] ?? '',
      call: json['call'] ?? json['20'] ?? '',
      email: json['email'] ?? json['21'] ?? '',
      whatsapp: json['whatsapp'] ?? json['22'] ?? '',
      size: json['size'] ?? json['23'],
      nbrPage: json['nbrPage'] ?? json['24'],
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
// book_detail_model.dart
import 'dart:convert';

class BookDetailResponse {
  final String? idBook;
  final String? bookBlanket;
  final String? bookTitle;
  final String? authorName;
  final String? description;
  final String? categoryTitle;
  final int? isPhysic;
  final dynamic? electronic;
  final int? isAudio;
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

  BookDetailResponse({
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

  factory BookDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookDetailResponse(
      idBook: json['idBook'] ?? json['0'] ?? '',
      bookBlanket: json['bookBlanket'] ?? json['1'] ?? '',
      bookTitle: json['bookTitle'] ?? json['2'] ?? '',
      authorName: json['authorName'] ?? json['3'] ?? '',
      description: json['description'] ?? json['4'] ?? '',
      categoryTitle: json['categoryTitle'] ?? json['5'] ?? '',
      isPhysic: _parseInt(json['isPhysic'] ?? json['6']),
      electronic: json['electronic'] ?? json['7'],
      isAudio: _parseInt(json['isAudio'] ?? json['8']),
      numberLike: _parseInt(json['numberLike'] ?? json['9']),
      numberNoLike: _parseInt(json['numberNoLike'] ?? json['10']),
      numberSubscribe: _parseInt(json['numberSubscribe'] ?? json['11']),
      numberView: _parseInt(json['numberView'] ?? json['12']),
      categoryBlanket: json['categoryBlanket'] ?? json['13'] ?? '',
      idAuthor: _parseInt(json['idAuthor'] ?? json['14']),
      name: json['name'] ?? json['15'] ?? '',
      firstName: json['firstName'] ?? json['16'] ?? '',
      profile: json['profile'] ?? json['17'] ?? '',
      available: _parseInt(json['available'] ?? json['18']),
      profession: json['profession'] ?? json['19'] ?? '',
      call: json['call'] ?? json['20'] ?? '',
      email: json['email'] ?? json['21'] ?? '',
      whatsapp: json['whatsapp'] ?? json['22'] ?? '',
      size: json['size'] ?? json['23'],
      nbrPage: json['nbrPage'] ?? json['24'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
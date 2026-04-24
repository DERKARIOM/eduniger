import 'dart:convert';
import 'dart:io';

import 'package:eduniger/features/livres/models/book_model.dart';
import 'package:eduniger/features/livres/models/detaille_book_model.dart';
import 'package:eduniger/features/livres/repositories/book_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../dto/book_dto.dart';
import '../dto/detaille_book_dto.dart';
import '../models/book_model.dart';
import '../models/detaille_book_model.dart';
import '../models/livres_model.dart';
import '../repositories/book_repository.dart';

class PostmantBookRepositorie implements BookRepository {
  static const String _baseUrl                 = 'https://api.eduniger.com';
  static const String _livreRecomandEndpoint   = '/recommended.php';
  static const String _detailEndpoint          = '/book.php';
  static const String _vueEndpoint             = '/insert_view.php';
  static const String _likeEndpoint            = '/insert_like.php';
  static const String _dislikeEndpoint         = '/insert_no_like.php';
  static const String _abonnerEndpoint         = '/insert_subscribe_book.php';
  static const String _commentEndpoint         = '/insert_comment.php';
  static const String _livreTelechargerEndpoint= '/download_book.php';
  static const String _livresEndpoint          = '/books.php';
  static const String _livreEmprunterEndpoint  = '/borrowed_books.php';



  @override
  Future<List<LivresModel>> livres(String numero) async {
    try {
      // Construction de l'URL avec les paramètres pour une requête GET
      final uri = Uri.parse('$_baseUrl$_livresEndpoint').replace(
        queryParameters: {
          'id_number': numero,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      String responseBody = response.body.trim();
      debugPrint("Livres body : $responseBody");

      List<LivresModel> livres = [];

      if (response.statusCode == 200 && responseBody.isNotEmpty) {
        final dynamic jsonData = jsonDecode(responseBody);

        if (jsonData is List) {
          livres = jsonData.map((json) => LivresModel.fromJson(json)).toList();
        } else if (jsonData is Map && jsonData.containsKey('error')) {
          debugPrint("Erreur API : ${jsonData['error']}");
        }
      } else {
        debugPrint("Erreur HTTP : ${response.statusCode}");
      }

      print("Livres retour : ${livres.length} livres");
      return livres;

    } on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) {
      debugPrint("Erreur Exception dans livres() : $e");
      rethrow;
    }
  }


  @override
  Future<List<Book>> livreElectronique(String numero) async {
    throw Exception('non implanter');
  }

  @override
  Future<List<Book>> livreAudio(String numero) async {
    throw Exception('non implanter');
  }

  @override
  Future<List<Book>> livreTelecharger(String numero, String version) async {
    throw Exception('non implanter');
  }

  @override
  Future<List<Book>> livreEmprunter(String numero) async {
    throw Exception('non implanter');
  }

  @override
  Future<String> abonner(String numero, String id_book) {
    // TODO: implement abonner
    throw UnimplementedError();
  }

  @override
  Future<String> comment(String numero, String id_book, String comment) {
    // TODO: implement comment
    throw UnimplementedError();
  }

  @override
  Future<BookDetailDto> detail(String numero, String id_book) async{
    try {
      // Construction de l'URL avec les paramètres pour une requête GET
      final uri = Uri.parse('$_baseUrl$_detailEndpoint').replace(
        queryParameters: {
          'id_number': numero,
          'id_book': id_book,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      String responseBody = response.body.trim();
      debugPrint("Detail body : $responseBody");
      BookDetailDto detail_livre = BookDetailDto();
      if (response.statusCode == 200 && responseBody.isNotEmpty) {
        final dynamic jsonData = jsonDecode(responseBody);
        //print("categorie  retour : ${categorie.length} categorie");
        if (jsonData is Map) {
          detail_livre = BookDetailDto.fromJson(jsonData);
        } else if (jsonData is List && jsonData.isNotEmpty) {
          detail_livre = BookDetailDto.fromJson(jsonData[0]);
        }
      }
      print(" detail du livre retourner : ${detail_livre}");
      return detail_livre;

    } on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) {
      debugPrint("Erreur Exception dans detail : $e");
      rethrow;
    }
     }

  @override
  Future<String> dislike(String numero, String id_book) {
    // TODO: implement dislike
    throw UnimplementedError();
  }

  @override
  Future<String> like(String numero, String id_book) {
    // TODO: implement like
    throw UnimplementedError();
  }

  @override
  Future<String> vue(String numero, String id_book) {
    // TODO: implement vue
    throw UnimplementedError();
  }


    /*
  @override
  Future<DetailleBookModel> detail(String numero, String idBook) async
  {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_detailEndpoint'),
      );

      request.fields['id_number'] = numero;
      request.fields['id_book'] = idBook;
      request.headers['Accept'] = 'application/json';

      var streamedResponse = await request.send();
      var response         = await http.Response.fromStream(streamedResponse);
      String responseBody  = response.body.trim();
      BookDetailDto bookDto;
      List<DetailleBookModel> livre = [];
      bookDto = BookDetailDto.fromJson(jsonDecode(responseBody));
      livre.add(DetailleBookModel(
        id: bookDto.idBook ?? '',
        couverture: bookDto.bookBlanket ??'',
        titre: bookDto.bookTitle ??'',
        description:bookDto.description ??'',
        titre_categorie: bookDto.categoryTitle ??'',
        est_pysique: bookDto.isPhysic ?? false,
        est_electronique: bookDto.electronic ?? false,
        est_audio: bookDto.isAudio ?? false,

      ));
      return livre;




    } on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) { rethrow; }
  }


  Future<String> _actionSimple(
      String endpoint, Map<String, String> fields, String actionName,
      )
  async {
    try {
      final response = await _post(endpoint, fields);
      final body     = response.body.trim();
      debugPrint("$actionName [body] : $body");

      if (body.toLowerCase() == 'ok' || response.statusCode == 200) {
        return 'success';
      }
      // Tentative JSON
      try {
        final json   = jsonDecode(body) as Map<String, dynamic>;
        final status = json['status']?.toString() ?? '';
        if (status == 'success') return 'success';
        return json['message']?.toString() ?? 'erreurServeur';
      } catch (_) {}

      return 'erreurServeur';
    } on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) { rethrow; }
  }

  @override
  Future<String> vue(String numero, String id_book) async {
    return _actionSimple(
      _vueEndpoint,
      {'id_number': numero, 'id_book': id_book},
      'vue',
    );
  }

  @override
  Future<String> like(String numero, String id_book) async {
    return _actionSimple(
      _likeEndpoint,
      {'id_number': numero, 'id_book': id_book},
      'like',
    );
  }

  @override
  Future<String> dislike(String numero, String id_book) async {
    return _actionSimple(
      _dislikeEndpoint,
      {'id_number': numero, 'id_book': id_book},
      'dislike',
    );
  }

  @override
  Future<String> abonner(String numero, String id_book) async {
    return _actionSimple(
      _abonnerEndpoint,
      {'id_number': numero, 'id_book': id_book},
      'abonner',
    );
  }

  @override
  Future<String> comment(String numero, String id_book, String comment) async {
    return _actionSimple(
      _commentEndpoint,
      {'id_number': numero, 'id_book': id_book, 'comment': comment},
      'comment',
    );
  }
  */
}
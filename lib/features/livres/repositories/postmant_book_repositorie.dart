import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
  Future<String> abonner(String numero, String id_book)async {
    String res='';
    String url = '$_baseUrl$_abonnerEndpoint';
    final dio = Dio();
    dio.options.headers['Accept'] = 'application/json';
    Response response = await  dio.postUri(
      Uri.parse(url),
      data: {
        'idNumber': numero,
        'idBook': id_book,
      },
    );
    String responseBody = response.data.toString();
    debugPrint("Like body : $responseBody");
    if (response.statusCode == 200 && responseBody.isNotEmpty) {
      jsonDecode(responseBody);
      if (responseBody == 'true') {
        return 'ok';
      }else{
        return 'erreurServeur';
      }
    }
    return res;

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
  Future<String> dislike(String numero, String id_book) async {
    // TODO: implement dislike
    String res='';
    String url = '$_baseUrl$_dislikeEndpoint';
    final dio = Dio();
    dio.options.headers['Accept'] = 'application/json';
    Response response = await  dio.postUri(
      Uri.parse(url),
      data: {
        'idNumber': numero,
        'idBook': id_book,
      },
    );
    String responseBody = response.data.toString();
    debugPrint("Like body : $responseBody");
    if (response.statusCode == 200 && responseBody.isNotEmpty) {
      jsonDecode(responseBody);
      if (responseBody == 'true') {
        return 'ok';
      }else{
        return 'erreurServeur';
      }
    }
    return res;
  }


  @override
  Future<String> vue(String numero, String id_book) async {
    // TODO: implement vue
    String res='';
    try {
      final uri = Uri.parse('$_baseUrl$_vueEndpoint');
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'idNumber': numero,
          'idBook': id_book,
        },
      );
      String responseBody = response.body.trim();
      if (response.statusCode == 200 && responseBody.isNotEmpty) {
        final dynamic jsonData = jsonDecode(responseBody);
        if (jsonData == '1') {
          res='ok';
          debugPrint("vue : $res");
        }
        else {
          return 'erreurServeur';
        }
      }
      return res;
    }catch (e) {
      rethrow;
    }

  }

// Dans PostmantBookRepositorie
  @override
  Future<String> reserverLivre(String numero, String idBook) async {
    try {
      final uri = Uri.parse('$_baseUrl$_detailEndpoint').replace(
        queryParameters: {
          'id_number': numero,
          'id_book': idBook,
        },
      );

      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );


      final body = res.body.trim();
      debugPrint("reserverLivre [${res.statusCode}] : $body");

      if (body.toLowerCase() == 'ok' || res.statusCode == 200) return 'success';
      if (body.contains('already'))   return 'deja_reserve';
      if (body.contains('not_found')) return 'introuvable';

      try {
        final json    = jsonDecode(body) as Map<String, dynamic>;
        final status  = json['status']?.toString() ?? '';
        if (status == 'success') return 'success';
        return json['message']?.toString() ?? 'erreurServeur';
      } catch (_) {}

      return 'erreurServeur';
    } on SocketException { throw Exception('pasDeConnexion'); }
    catch (e) { rethrow; }
  }

  @override
  Future<String> like(String numero, String id_book) async {
    // TODO: implement like
    String res='';
    String url = '$_baseUrl$_likeEndpoint';
    final dio = Dio();
    dio.options.headers['Accept'] = 'application/json';
    Response response = await  dio.postUri(
        Uri.parse(url),
        data: {
          'idNumber': numero,
          'idBook': id_book,
        },
    );
    String responseBody = response.data.toString();
    debugPrint("Like body : $responseBody");
    if (response.statusCode == 200 && responseBody.isNotEmpty) {
      jsonDecode(responseBody);
      if (responseBody == 'true') {
        return 'ok';
      }else{
        return 'erreurServeur';
      }
    }
    return res;
  }


}
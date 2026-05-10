// services/recommendation_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../autheurs/model/author_model.dart';
import '../../livres/dto/book_dto.dart';
import '../../livres/models/book_model.dart';
import '../../structures/model/structure_model.dart';


class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      message: message,
      data: null,
      statusCode: statusCode,
    );
  }
}
class RecommendationService {
  static const String baseUrl = 'https://api.eduniger.com';

  // Méthode générique pour les requêtes GET
  static Future<http.Response> _get(String endpoint, Map<String, String> queryParams) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé');
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Méthode pour traiter les réponses de manière robuste
  static dynamic _handleResponse(http.Response response) {
    // 1. Vérifier si le corps est vide
    if (response.body.isEmpty) {
      return [];
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Nettoyage : On décode en UTF8 et on enlève les espaces/caractères invisibles
        String source = utf8.decode(response.bodyBytes,allowMalformed:true ).trim();

        // Tentative de décodage
        return json.decode(source);
      } catch (e) {
        debugPrint('❌ Erreur JSON: $e');
        // Affiche les 100 derniers caractères pour voir si c'est coupé
        debugPrint('Fin du body: ${response.body.substring(response.body.length - 20)}');
        throw Exception('Format JSON invalide');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée (404)');
    } else if (response.statusCode == 401) {
      throw Exception('Session expirée ou non autorisé (401)');
    } else {
      throw Exception('Erreur serveur (${response.statusCode})');
    }
  }
  // 1. Récupérer les livres recommandés

  static Future<ApiResponse<List<Book>>> getRecommendedBooks({
    required String idNumber,
    required String version,
  }) async
  {
    try {
      final response = await _get(
        '/recommended.php',
        {
          'id_number': idNumber,
          'version': version,
        },
      );

      final data = _handleResponse(response);

      print("les livres recommandés sont : ");
      print(data);
      List<Book> books = [];
      //books=data;

      if (data is List) {

        books = data.map((item) => Book.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('books')) {
        books = (data['books'] as List)
            .map((item) => Book.fromJson(item))
            .toList();
      }

      return ApiResponse.success(books, message: 'Livres récupérés avec succès');

    } catch (e) {
      print('❌ ERREUR DANS getRecommendedBooks: $e');
      return ApiResponse.error('Erreur lors de la récupération des livres: $e ');
      //return ApiResponse.error('Erreur lors de la récupération des livres: $e');

    }
  }


  // 2. Récupérer les structures adhérées
  static Future<ApiResponse<List<Structure>>> getJoinedStructures({
    required String idNumber,

  }) async {
    try {
      final response = await _get(
        '/structure.php',
        {'id_user': idNumber},
      );

      final data = _handleResponse(response);
      print("les structures adhérées sont : ");
      print(data);
      List<Structure> structures = [];
      if (data is List) {

        structures = data.map((item) => Structure.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('structures')) {
        structures = (data['structures'] as List)
            .map((item) => Structure.fromJson(item))
            .toList();
      }

      return ApiResponse.success(structures);

    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des structures: $e');
    }
  }

  // 3. Récupérer les structures recommandées
  static Future<ApiResponse<List<Structure>>> getRecommendedStructures({
    required String idNumber,
  }) async {
    try {
      final response = await _get(
        '/structure_top.php',
        {'id_user': idNumber},
      );

      final data = _handleResponse(response);
      print("les structures recommandées sont : ");
      print(data);
      List<Structure> structures = [];
      if (data is List) {

        structures = data.map((item) => Structure.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('structures')) {
        structures = (data['structures'] as List)
            .map((item) => Structure.fromJson(item))
            .toList();
      }

      return ApiResponse.success(structures);

    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des structures recommandées: $e');
    }
  }

  // 4. Récupérer les auteurs recommandés
  static Future<ApiResponse<List<Author>>> getRecommendedAuthors({
    required String idNumber,
  }) async {
    try {
      final response = await _get(
        '/author_top.php',
        {'id_user': idNumber},
      );

      final data = _handleResponse(response);
      print(data);
      List<Author> authors = [];
      if (data is List) {
        authors = data.map((item) => Author.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('authors')) {
        authors = (data['authors'] as List)
            .map((item) => Author.fromJson(item))
            .toList();
      }

      return ApiResponse.success(authors);

    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des auteurs: $e');
    }
  }

  // Méthode pour récupérer toutes les recommandations en une fois
  static Future<Map<String, dynamic>> getAllRecommendations({
    required String idNumber,
    required String version,
  }) async {
    final results = await Future.wait([
      getRecommendedBooks(idNumber: idNumber, version: version),
      getJoinedStructures(idNumber: idNumber),
      getRecommendedStructures(idNumber: idNumber),
      getRecommendedAuthors(idNumber: idNumber),
      //getAllBooks(idNumber: idNumber),
    ]);

    for (var result in results) {
      if (result is ApiResponse && !result.success) {
        throw Exception(result.message); // Ceci déclenchera snapshot.hasError
      }
    }

    return {

      'recommendedBooks': results[0],
      'joinedStructures': results[1],
      'recommendedStructures': results[2],
      'recommendedAuthors': results[3],
      //'allBooks': results[4],
    };
  }
}
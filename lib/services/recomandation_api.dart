// services/recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/modelAutheur.dart';
import '../models/modelBook.dart';
import '../models/modelStructure.dart';

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
  static const String baseUrl = 'https://eduniger.com/api';

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

  // Méthode pour traiter les réponses
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Erreur de décodage JSON: ${response.body}');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée');
    } else if (response.statusCode == 401) {
      throw Exception('Non autorisé');
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }

  // 1. Récupérer les livres recommandés
  static Future<ApiResponse<List<Book>>> getRecommendedBooks({
    required String idNumber,
    required String version,
  }) async {
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
      if (data is List) {

        books = data.map((item) => Book.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('books')) {
        books = (data['books'] as List)
            .map((item) => Book.fromJson(item))
            .toList();
      }

      return ApiResponse.success(books, message: 'Livres récupérés avec succès');

    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des livres: $e');
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
/*
  // 5. Récupérer tous les livres
  static Future<ApiResponse<List<Book>>> getAllBooks({
    required String idNumber,
  }) async {
    try {
      final response = await _get(
        '/books.php',
        {'id_number': idNumber},
      );

      final data = _handleResponse(response);

      List<Book> books = [];
      if (data is List) {
        books = data.map((item) => Book.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('books')) {
        books = (data['books'] as List)
            .map((item) => Book.fromJson(item))
            .toList();
      }

      return ApiResponse.success(books);

    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des livres: $e');
    }
  }
*/
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

/*
// services/recomandation_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/modelAutheur.dart';
import '../models/modelBook.dart';
import '../models/modelStructure.dart';

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
  static const String baseUrl = 'https://eduniger.com/api';

  // Méthode générique pour les requêtes GET
  static Future<http.Response> _get(String endpoint, Map<String, String> queryParams) async {
    try {
      // ✅ VALIDATION DES PARAMÈTRES
      print('\n📋 Query Parameters:');
      queryParams.forEach((key, value) {
        print('  - $key: "$value" (empty: ${value.isEmpty})');
      });

      // Vérifier qu'aucun paramètre n'est vide
      final emptyParams = queryParams.entries
          .where((entry) => entry.value.isEmpty)
          .map((entry) => entry.key)
          .toList();

      if (emptyParams.isNotEmpty) {
        throw Exception('Paramètres vides détectés: ${emptyParams.join(", ")}');
      }

      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

      print('📡 REQUEST: $uri'); // Log de la requête

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

      print('✅ STATUS CODE: ${response.statusCode}'); // Log du status
      print('📦 RAW RESPONSE: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...'); // Log de la réponse
      // Logger les premiers caractères de la réponse
      if (response.body.isNotEmpty) {
        final preview = response.body.length > 500
            ? '${response.body.substring(0, 500)}...'
            : response.body;
        print('📦 RAW RESPONSE: $preview');
      } else {
        print('⚠️ EMPTY RESPONSE BODY');
      }
      return response;
    } catch (e) {
      print('❌ ERROR in _get: $e');
      rethrow;
    }
  }

  // Méthode pour traiter les réponses
  static dynamic _handleResponse(http.Response response) {
    // ✅ Gérer les réponses vides
    if (response.body.isEmpty || response.body.trim().isEmpty) {
      print('⚠️ Response body is empty, returning empty list');
      return []; // Retourner une liste vide au lieu de planter
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        print('✅ JSON DECODED SUCCESSFULLY');
        return decoded;
      } catch (e) {
        print('❌ JSON DECODE ERROR: $e');
        print('📄 Response body: ${response.body}');
        throw Exception('Erreur de décodage JSON: ${response.body}');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée');
    } else if (response.statusCode == 401) {
      throw Exception('Non autorisé');
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }

  // 1. Récupérer les livres recommandés
  static Future<ApiResponse<List<Book>>> getRecommendedBooks({
    required String idNumber,
    required String version,
  }) async {
    try {
      print('\n🔥 FETCHING RECOMMENDED BOOKS...');
      print('\n🔥 ========== FETCHING RECOMMENDED BOOKS ==========');
      print('Parameters: idNumber="$idNumber", version="$version"');

      // ✅ VALIDATION
      if (idNumber.isEmpty) {
        throw Exception('idNumber est vide !');
      }
      if (version.isEmpty) {
        throw Exception('version est vide !');
      }

      final response = await _get(
        '/recommended.php',
        {
          'id_number': idNumber,
          'version': version,
        },
      );

      final data = _handleResponse(response);
      print('📚 Books data type: ${data.runtimeType}');

      List<Book> books = [];

      if (data is List) {
        print('✅ Data is a List with ${data.length} items');

        // Afficher le premier élément pour voir sa structure
        if (data.isNotEmpty) {
          print('📖 First book structure: ${data[0]}');
        }

        try {
          books = data.map((item) {
            print('🔄 Parsing book: $item');
            return Book.fromJson(item);
          }).toList();

          print('✅ Successfully parsed ${books.length} books');
        } catch (e) {
          print('❌ Error parsing books: $e');
          return ApiResponse.error('Erreur lors du parsing des livres: $e');
        }
      } else if (data is Map && data.containsKey('books')) {
        print('✅ Data is a Map with "books" key');
        final booksList = data['books'] as List;
        print('📚 Books list length: ${booksList.length}');

        books = booksList.map((item) => Book.fromJson(item)).toList();
      } else {
        print('⚠️ Unexpected data format: ${data.runtimeType}');
        print('📄 Data content: $data');
      }

      print('✅ FINAL RESULT: ${books.length} books loaded\n');
      return ApiResponse.success(books, message: 'Livres récupérés avec succès');

    } catch (e) {
      print('❌ BOOKS ERROR: $e\n');
      return ApiResponse.error('Erreur lors de la récupération des livres: $e');
    }
  }

  // 2. Récupérer les structures adhérées
  static Future<ApiResponse<List<Structure>>> getJoinedStructures({
    required String idNumber,
  }) async {
    try {
      print('\n🔥 FETCHING JOINED STRUCTURES...');
      print('Parameter: idNumber="$idNumber"');

      // ✅ VALIDATION
      if (idNumber.isEmpty) {
        throw Exception('idNumber est vide !');
      }
      final response = await _get(
        '/structure.php',
        {'id_user': idNumber},
      );

      final data = _handleResponse(response);
      print('🏢 Structures data type: ${data.runtimeType}');

      List<Structure> structures = [];

      if (data is List) {
        print('✅ Data is a List with ${data.length} items');

        if (data.isNotEmpty) {
          print('🏛️ First structure: ${data[0]}');
        }

        structures = data.map((item) => Structure.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('structures')) {
        structures = (data['structures'] as List)
            .map((item) => Structure.fromJson(item))
            .toList();
      }

      print('✅ FINAL RESULT: ${structures.length} structures loaded\n');
      return ApiResponse.success(structures);

    } catch (e) {
      print('❌ STRUCTURES ERROR: $e\n');
      return ApiResponse.error('Erreur lors de la récupération des structures: $e');
    }
  }

  // 3. Récupérer les structures recommandées
  static Future<ApiResponse<List<Structure>>> getRecommendedStructures({
    required String idNumber,
  }) async {
    try {
      print('\n🔥 FETCHING RECOMMENDED STRUCTURES...');
      print('Parameter: idNumber="$idNumber"');

      // ✅ VALIDATION
      if (idNumber.isEmpty) {
        throw Exception('idNumber est vide !');
      }
      final response = await _get(
        '/structure_top.php',
        {'id_user': idNumber},
      );

      final data = _handleResponse(response);

      List<Structure> structures = [];

      if (data is List) {
        print('✅ Data is a List with ${data.length} items');
        structures = data.map((item) => Structure.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('structures')) {
        structures = (data['structures'] as List)
            .map((item) => Structure.fromJson(item))
            .toList();
      }

      print('✅ FINAL RESULT: ${structures.length} recommended structures\n');
      return ApiResponse.success(structures);

    } catch (e) {
      print('❌ RECOMMENDED STRUCTURES ERROR: $e\n');
      return ApiResponse.error('Erreur: $e');
    }
  }

  // 4. Récupérer les auteurs recommandés
  static Future<ApiResponse<List<Author>>> getRecommendedAuthors({
    required String idNumber,
  }) async {
    try {
      print('\n🔥 FETCHING RECOMMENDED AUTHORS...');
      print('Parameter: idNumber="$idNumber"');

      // ✅ VALIDATION
      if (idNumber.isEmpty) {
        throw Exception('idNumber est vide !');
      }
      final response = await _get(
        '/author_top.php',
        {'id_user': idNumber},
      );

      final data = _handleResponse(response);
      print('👥 Authors data type: ${data.runtimeType}');

      List<Author> authors = [];

      if (data is List) {
        print('✅ Data is a List with ${data.length} items');

        if (data.isNotEmpty) {
          print('👤 First author: ${data[0]}');
        }

        authors = data.map((item) => Author.fromJson(item)).toList();
      } else if (data is Map && data.containsKey('authors')) {
        authors = (data['authors'] as List)
            .map((item) => Author.fromJson(item))
            .toList();
      }

      print('✅ FINAL RESULT: ${authors.length} authors loaded\n');
      return ApiResponse.success(authors);

    } catch (e) {
      print('❌ AUTHORS ERROR: $e\n');
      return ApiResponse.error('Erreur: $e');
    }
  }
}
*/
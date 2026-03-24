import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/modelDetailBook.dart';
import '../models/modelUser.dart';

// auth_response.dart
class AuthResponse {
  final String status;
  final String message;
  final int code;
  final BookDetailResponse? data;

  AuthResponse({
    required this.status,
    required this.message,
    required this.code,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? 'success',
      message: json['message'] ?? '',
      code: json['code'] ?? 200,
      data: json['data'] != null
          ? BookDetailResponse.fromJson(json['data'])
          : null,
    );
  }

  factory AuthResponse.error(String message, {int code = 500}) {
    return AuthResponse(
      status: 'error',
      message: message,
      code: code,
    );
  }

  factory AuthResponse.success(BookDetailResponse data) {
    return AuthResponse(
      status: 'success',
      message: 'Opération réussie',
      code: 200,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'code': code,
      'data': data?.toJson(),
    };
  }
}


class DetailbookApi {
  static const String baseUrl = 'https://eduniger.com/api';
  static const String bookEndpoint = '/book.php';

  static Future<AuthResponse> getBookDetail({
    required String id_user,
    required String id_book,
  }) async {
    try {
      // Construction de l'URL avec les paramètres de requête pour un GET
      final Uri url = Uri.parse('$baseUrl$bookEndpoint').replace(
        queryParameters: {
          'id_number': id_user,
          'id_book': id_book,
        },
      );

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      String responseBody = response.body.trim();

      // 1. Vérifier si la réponse est vide
      if (responseBody.isEmpty) {
        return AuthResponse.error(
          'Réponse vide du serveur',
          code: response.statusCode,
        );
      }

      // 2. Tentative de décodage JSON
      try {
        final dynamic decodedResponse = json.decode(responseBody);

        // Cas A : La réponse est une Map (Objet JSON)
        if (decodedResponse is Map<String, dynamic>) {

          // Si la réponse contient déjà idBook, c'est l'objet direct
          if (decodedResponse.containsKey('idBook')) {
            return AuthResponse.success(
                BookDetailResponse.fromJson(decodedResponse)
            );
          }

          // Si la réponse suit le format standard {status, message, data}
          if (decodedResponse.containsKey('data')) {
            return AuthResponse.fromJson(decodedResponse);
          }

          // Sinon, on essaie de créer l'objet avec ce qu'on a
          return AuthResponse.success(
              BookDetailResponse.fromJson(decodedResponse)
          );
        }

        return AuthResponse.error('Format JSON non supporté');

      } catch (e) {
        // 3. Gestion si la réponse n'est pas du JSON (ex: erreur PHP texte)
        if (response.statusCode == 200) {
          return AuthResponse.error('Erreur de formatage des données (JSON invalide)');
        }
        return AuthResponse.error(
          'Erreur serveur (${response.statusCode}): $responseBody',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResponse.error(
        'Erreur réseau: ${e.toString()}',
        code: 500,
      );
    }
  }
}
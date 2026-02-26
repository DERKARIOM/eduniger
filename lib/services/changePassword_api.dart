import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Important pour multipart
import '../models/modelUser.dart';
import 'dart:convert';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/modelUser.dart';

class AuthService {
  static const String baseUrl = 'https://eduniger.com/api';
  static const String loginEndpoint = '/password_change.php';

  static Future<AuthResponse> changePassword({
    required String id_number,
    required String mail,
    required String password,

  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$loginEndpoint'),
      );

      request.fields['id_number'] = id_number;
      request.fields['email'] = mail;
      request.fields['password_new'] = password;
      request.headers['Accept'] = 'application/json';

      // 1. Envoi unique de la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      String responseBody = response.body.trim();

      // 2. Gestion des réponses en texte brut (Cas d'erreur PHP)
      if (responseBody == "noFoundIdNumberOrEmail") {
        return AuthResponse(status: 'error', message: 'numéro ou email incorrect', code: 401);
      }


      // 3. Tentative de décodage JSON
      try {
        Map<String, dynamic> responseData = json.decode(responseBody);
        print("JSON REÇU: $responseData");

        // Si l'API renvoie directement l'utilisateur (format plat de Postman)
        if (responseData.containsKey('name')) {
          return AuthResponse.fromJson({
            "status": "success",
            "code": 200,
            "message": "Connexion réussie",
            "data": {
              "user": responseData, // On met l'objet entier ici
              "accessToken": "token_dummy"
            }
          });
        }

        // Si l'API renvoie déjà un format structuré
        return AuthResponse.fromJson(responseData);

      } catch (e) {
        // Si ce n'est pas du JSON et pas un message d'erreur connu
        return AuthResponse(
            status: 'error',
            message: 'Réponse serveur invalide: $responseBody',
            code: response.statusCode
        );
      }

    } catch (e) {
      return AuthResponse(
        status: 'error',
        code: 500,
        message: 'Erreur réseau: $e',
      );
    }
  }

  static Future<http.Response> authenticatedGet(String endpoint, String accessToken) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
  }
}
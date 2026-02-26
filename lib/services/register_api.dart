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
  static const String loginEndpoint = '/register.php';

  static Future<AuthResponse> register({
    required String id_number,
    required String name,
    required String first_name,
    required String email,
    required String password,
    required String profession,
    required String version,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$loginEndpoint'),
      );

      request.fields['id_user'] = id_number;
      request.fields['name'] = name;
      request.fields['first_name'] = first_name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['profession'] = profession;
      request.fields['version'] = version;
      request.headers['Accept'] = 'application/json';

      // 1. Envoi unique de la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      String responseBody = response.body.trim();

      // --- GESTION DES RÉPONSES EN TEXTE BRUT ---

      // CAS DE SUCCÈS : Le serveur renvoie "ok"
      if (responseBody.toLowerCase() == "ok") {
        return AuthResponse(
          status: 'success',
          message: 'Inscription réussie',
          code: 200,
          //data: User(id: 0, name: name, email: email), // On crée un objet utilisateur fictif car le serveur n'a renvoyé que "ok"
        );
      }

      // CAS D'ERREURS CONNUES
      if (responseBody == "existingAccount") {
        return AuthResponse(status: 'error', message: 'Ce numéro de téléphone est déjà utilisé', code: 401);
      }
      if (responseBody == "existingEmail") {
        return AuthResponse(status: 'error', message: 'Cet email est déjà utilisé', code: 404);
      }
      if (responseBody.contains("Renplir les champ")) {
        return AuthResponse(status: 'error', message: 'Veuillez remplir tous les champs correctement', code: 400);
      }

      // --- TENTATIVE DE DÉCODAGE SI LE SERVEUR RENVOIE DU JSON ---
      try {
        Map<String, dynamic> responseData = json.decode(responseBody);
        return AuthResponse.fromJson(responseData);
      } catch (e) {
        // Si ce n'est pas du JSON et que ce n'est pas "ok"
        return AuthResponse(
            status: 'error',
            message: 'Réponse serveur: $responseBody',
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
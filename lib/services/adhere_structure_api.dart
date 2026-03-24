import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/modelUser.dart';

class Aderers {
  static const String baseUrl = 'https://eduniger.com/api';
  static const String loginEndpoint = '/adherer_struct.php';

  static Future<AuthResponse> adhere({
    required String id_number,
    required String idStructure,

  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$loginEndpoint'),
      );

      request.fields['id_user'] = id_number;
      request.fields['id_struct'] = idStructure;

      request.headers['Accept'] = 'application/json';

      // 1. Envoi unique de la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      String responseBody = response.body.trim();

      // --- GESTION DES RÉPONSES EN TEXTE BRUT ---

      // CAS DE SUCCÈS : Le serveur renvoie "ok"
      if (responseBody == "true") {
        return AuthResponse(
          status: 'success',
          message: 'adherer avec succe',
          code: 200,
          //data: User(id: 0, name: name, email: email), // On crée un objet utilisateur fictif car le serveur n'a renvoyé que "ok"
        );
      }else if (responseBody == "ras") {
        return AuthResponse(
          status: 'error',
          message: 'Vous êtes déjà adhéré à cette structure',
            code: 404);

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
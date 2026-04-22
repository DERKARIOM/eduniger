import 'dart:convert';
import 'dart:io';

import 'package:eduniger/features/utilisateurs/dto/userdto.dart';
import 'package:eduniger/features/utilisateurs/repositories/user_repositorie.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class PostmantUserRepositoie implements UserRepositorie {
  static const String baseUrl = 'https://api.eduniger.com';
  static const String loginEndpoint = '/login.php';
  static const String registerEndpoint = '/register.php';
  static const String changePasswordEndpoint = '/password_change.php';


  //UserModel? instant;

  @override
  Future<String> changer_mot_de_passe(String numero, String email,
      String mot_de_passe_confirmer)async
  {


      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl$changePasswordEndpoint'),
        );

        request.fields['id_number'] = numero;
        request.fields['mail']      = email;
        request.fields['password']  = mot_de_passe_confirmer;
        request.headers['Accept']   = 'application/json';

        var streamedResponse = await request.send();
        var response         = await http.Response.fromStream(streamedResponse);
        String responseBody  = response.body.trim();

        debugPrint("ChangePassword response [${response.statusCode}] : $responseBody");

        // ── Réponses texte brut ──────────────────────────────────────────
        if (responseBody.toLowerCase() == 'ok' || response.statusCode == 200) {
          return 'success';
        }
        if (responseBody.contains('noFoundIdNumberOrEmail')) {
          return 'noFoundIdNumberOrEmail';
        }

        // ── Tentative JSON ────────────────────────────────────────────────
        try {
          final Map<String, dynamic> json = jsonDecode(responseBody);
          final String status  = json['status']?.toString()  ?? '';
          final String message = json['message']?.toString() ?? '';
          if (status == 'success') return 'success';
          if (message.isNotEmpty)  return message;
        } catch (_) {
          // Pas du JSON, on continue
        }

        return 'erreurServeur';

      } on SocketException {
        throw Exception('pasDeConnexion');
      } catch (e) {
        throw Exception(e.toString());
      }

  }

  @override
  Future<String> changer_profil(UserModel user) {
    // TODO: implement changer_profil
    throw UnimplementedError();
  }

  @override
  Future<String> creer_compte(
      String numero, String email, String nom,
      String prenom, String mot_de_passe, String profession, String version,String token
      ) async
  {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$registerEndpoint'),
      );

      request.fields['id_user'] = numero;
      request.fields['name'] = nom;
      request.fields['first_name'] = prenom;
      request.fields['email'] = email;
      request.fields['password'] = mot_de_passe;
      request.fields['profession'] = profession;
      request.fields['version'] = version;
      request.fields['fcm_token'] = token;
      request.headers['Accept'] = 'application/json';


      var streamedResponse = await request.send();
      var response         = await http.Response.fromStream(streamedResponse);
      String responseBody  = response.body.trim();

      debugPrint("Register response [${response.statusCode}] : $responseBody");

      // ── Réponses texte brut ──────────────────────────────────────────
      if (responseBody.toLowerCase() == "ok") {
        return 'success';
      }
      if (responseBody == 'existingAccount') return 'existingAccount';
      if (responseBody == 'existingEmail')   return 'existingEmail';
      if (responseBody.toLowerCase().contains('renplir les champ') ||
          responseBody.toLowerCase().contains('remplir les champ')) {
        return 'champVide';
      }

      // ── Tentative JSON ────────────────────────────────────────────────
      try {
        final Map<String, dynamic> json = jsonDecode(responseBody);
        final String status  = json['status']?.toString()  ?? '';
        final String message = json['message']?.toString() ?? '';
        if (status == 'success') return 'success';
        if (message.isNotEmpty)  return message;
      } catch (_) {
        // Pas du JSON, on continue
      }

      // ── Réponse inconnue ──────────────────────────────────────────────
      return 'erreurServeur';

    } on SocketException {
      throw Exception('pasDeConnexion');
    }  catch (e) {
      throw Exception(e.toString());
    }
  }
  @override
  Future<UserModel> seconecter(String numero, String mot_de_passe, String token, String version) async
  {
    //instant?.se_connecter(numero, mot_de_passe);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$loginEndpoint'),
      );

      request.fields['id_number'] = numero;
      request.fields['password'] = mot_de_passe;
      request.fields['token'] = token;
      request.fields['version'] = version;
      request.headers['Accept'] = 'application/json';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      String responseBody = response.body.trim();

      // 1. Gestion des erreurs en texte brut
      if (responseBody == "incorrectPassword") {
        throw Exception("Mot de passe incorrect");
      }
      if (responseBody == "user not found" || responseBody == "accountNotExist") {
        throw Exception("Compte inexistant");
      }

      // 2. Tentative de décodage JSON
      Map<String, dynamic> responseData;
      try {
        print(responseBody);
        responseData = json.decode(responseBody);
        print(responseData);
      } catch (e) {
        throw Exception("Réponse serveur invalide (Format non JSON)");
      }

      // 3. Extraction des données de l'utilisateur
      // Si l'API renvoie directement l'utilisateur (format plat)
      if (responseData.containsKey('name')&&response.statusCode==200) {
        UserDto dto = UserDto.fromJson(responseData);
        print('dto ${dto}');
        UserModel user = UserModel(
            idantifiant: dto.id,
            nom: dto.name ?? '',
            prenom: dto.firstName ?? '',
            numero: numero,
            mail: dto.email ?? '',
            mot_de_passe: mot_de_passe,
            profession: dto.profession ?? '',
            role: dto.role ?? 0,
            accessToken: token,

           );
        return user;
      }



      throw Exception("Données utilisateur introuvables dans la réponse");

    } catch (e) {
      print(e);
      // On propage l'erreur pour qu'elle soit gérée par l'UI (avec un try/catch)
      rethrow;
    }
  }




    static Future<http.Response> authenticatedGet(String endpoint, String accessToken) async {
      return await http.get(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
    }


  

}
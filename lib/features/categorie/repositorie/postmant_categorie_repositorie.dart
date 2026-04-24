import 'dart:convert';
import 'dart:io';

import 'package:eduniger/features/categorie/models/modelCategorie.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'categorie_repositorie.dart';

class PostmantCategorieRepositorie extends CategorieRepositorie {
  static const String _baseUrl                 = 'https://api.eduniger.com';
  static const String _ctegorieEndpoint   = '/category.php';

  @override
  Future<List<MCategorie>> categories(String numero) async{
    try {
      // Construction de l'URL avec les paramètres pour une requête GET
      final uri = Uri.parse('$_baseUrl$_ctegorieEndpoint').replace(
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

      List<MCategorie> categorie = [];

      if (response.statusCode == 200 && responseBody.isNotEmpty) {
        final dynamic jsonData = jsonDecode(responseBody);

        if (jsonData is List) {
          categorie = jsonData.map((json) => MCategorie.fromJson(json)).toList();
        } else if (jsonData is Map && jsonData.containsKey('error')) {
          debugPrint("Erreur API : ${jsonData['error']}");
        }
      } else {
        debugPrint("Erreur HTTP : ${response.statusCode}");
      }

      //print("categorie  retour : ${categorie.length} categorie");
      return categorie;

    } on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) {
      debugPrint("Erreur Exception dans categorie() : $e");
      rethrow;
    }
  }
  
}
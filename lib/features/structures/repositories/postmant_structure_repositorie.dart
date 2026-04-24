import 'dart:convert';
import 'dart:io';

import 'package:eduniger/features/structures/model/structure_model.dart';
import 'package:eduniger/features/structures/repositories/structure_repositorie.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PostmantStructureRepositorie implements StructureRepositorie {
  static const String _baseUrl                 = 'https://api.eduniger.com';
  static const String _structureEndpoint   = '/structure_more.php';

  @override
  Future<List<Structure>> structures(String numero) async{
    try {
      final uri = Uri.parse('$_baseUrl$_structureEndpoint').replace(
        queryParameters: {
          'id_number': numero,
        },
      );
      final response = await  http.get(uri, headers: {
        'Accept': 'application/json',
      });
      String responseBody = response.body.trim();
      List<Structure> structures = [];
      if (response.statusCode == 200 && responseBody.isNotEmpty) {
        final dynamic jsonData = jsonDecode(responseBody);
        if (jsonData is List) {
          structures = jsonData.map((json) => Structure.fromJson(json)).toList();
        }
        else if (jsonData is Map && jsonData.containsKey('error')) {
          debugPrint("Erreur API : ${jsonData['error']}");
        }
      } else {
        debugPrint("Erreur HTTP : ${response.statusCode}");
      }
      return structures;
    }on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) {
      rethrow;
    }
  }



}
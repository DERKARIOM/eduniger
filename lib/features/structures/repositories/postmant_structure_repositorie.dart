import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eduniger/features/livres/models/book_model.dart';
import 'package:eduniger/features/structures/model/structure_model.dart';
import 'package:eduniger/features/structures/repositories/structure_repositorie.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PostmantStructureRepositorie implements StructureRepositorie {
  static const String _baseUrl                 = 'https://api.eduniger.com';
  static const String _structureEndpoint   = '/structure_more.php';
  static const String _book_structureEndpoint   = '/struct_book.php';

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
/*
  @override
  Future<List<Book>> livre_structure(String numero, int id)async {
    List<Book> livre=[];
    try{
      final Dio dio = Dio();
      String url='$_baseUrl$_book_structureEndpoint';
      Response response= await dio.post(
          url,
          data: {
            'idNumber':numero,
            'idStruct':id,
          },
          options: Options(
            headers: {
              'Accept': 'application/json',
            },

          )
      );
      if(response.statusCode==200){
        final dynamic jsonData = response.data;
        debugPrint(jsonData.toString());
        if (jsonData is List) {
          livre = jsonData.map((json) => Book.fromJson(json)).toList();
        }
        else if (jsonData is Map && jsonData.containsKey('error')) {
          debugPrint("Erreur API : ${jsonData['error']}");
        }
      }else{
        debugPrint("Erreur HTTP : ${response.statusCode}");
      }
      return livre;

    }catch(e){
      throw Exception('erreur de chargement ');
    }

    throw UnimplementedError();
  }
*/
  @override
  Future<List<Book>> livre_structure(String numero, int id) async {
    try {
      final Dio dio = Dio();
      String url = '$_baseUrl$_book_structureEndpoint';

      FormData formData = FormData.fromMap({
        'idNumber': numero,
        'idStruct': id,
      });

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          // Permet de voir le contenu de l'erreur même si le code est 400
          validateStatus: (status) => status! < 500,
        ),
      );

      List<Book> livres = [];

      if (response.statusCode == 200) {
        final dynamic jsonData = response.data;

        // Si PHP renvoie une chaîne JSON, Dio la décode automatiquement
        if (jsonData is List) {
          livres = jsonData.map((json) => Book.fromJson(json)).toList();
        } else if (jsonData is Map && jsonData.containsKey('error')) {
          debugPrint("Erreur API : ${jsonData['error']}");
        }
      } else {
        // Si c'est toujours 400, on affiche le corps de la réponse pour comprendre pourquoi
        debugPrint("Erreur HTTP ${response.statusCode}: ${response.data}");
      }

      return livres;

    } on DioException catch (e) {
      debugPrint("Erreur Dio : ${e.type} - ${e.message}");
      if (e.response != null) {
        debugPrint("Détails serveur : ${e.response?.data}");
      }
      throw Exception('Erreur de connexion au serveur');
    } catch (e) {
      debugPrint("Erreur inattendue : $e");
      throw Exception('Erreur de chargement des livres');
    }
  }

}
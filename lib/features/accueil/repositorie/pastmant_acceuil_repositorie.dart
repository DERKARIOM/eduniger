import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduniger/features/accueil/repositorie/recomandation_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../autheurs/model/author_model.dart';
import '../../livres/models/book_model.dart';
import '../../structures/model/structure_model.dart';
import '../model/acceuil_model.dart';
import 'accueil_repositorie.dart';

class PostmantAccueilRepository implements AccueilRepository {
  static const String _baseUrl = 'https://api.eduniger.com';

  // ── Requête POST mutualisée (pour adhérer/détacher) ───────────────────
  Future<http.Response> _post(
      String endpoint,
      Map<String, String> fields,
      ) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$_baseUrl$endpoint'));
    req.fields.addAll(fields);
    req.headers['Accept'] = 'application/json';
    return http.Response.fromStream(await req.send());
  }

  // ══════════════════════════════════════════════════════════════════════
  // CHARGEMENT — réutilise exactement ton RecommendationService existant
  // ══════════════════════════════════════════════════════════════════════
  @override
  Future<AccueilData> chargerAccueil(String numero, String version) async {
    try {
      // ← ton service existant, on l'appelle directement
      final Map<String, dynamic> results =
      await RecommendationService.getAllRecommendations(
        idNumber: numero,
        version: version,
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException(
              'Le chargement prend trop de temps. Vérifiez votre connexion.');
        },
      );

      // ← extraction exactement comme dans ton ancien FutureBuilder
      final booksResponse =
      results['recommendedBooks'] as ApiResponse<List<Book>>;
      final structuresAddResponse =
      results['joinedStructures'] as ApiResponse<List<Structure>>;
      final structuresRecomResponse =
      results['recommendedStructures'] as ApiResponse<List<Structure>>;
      final authorsResponse =
      results['recommendedAuthors'] as ApiResponse<List<Author>>;

      debugPrint('📚 Livres      : ${booksResponse.data?.length ?? 0}');
      debugPrint('🏛️ Adhérées   : ${structuresAddResponse.data?.length ?? 0}');
      debugPrint('🏛️ Recommandées: ${structuresRecomResponse.data?.length ?? 0}');
      debugPrint('✍️  Auteurs    : ${authorsResponse.data?.length ?? 0}');

      return AccueilData(
        livresRecomandes      : booksResponse.data      ?? [],
        structuresAdherees    : structuresAddResponse.data   ?? [],
        structuresRecomandees : structuresRecomResponse.data ?? [],
        auteurs               : authorsResponse.data    ?? [],
      );
    } on TimeoutException {
      throw Exception('timeout');
    } on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // ADHÉRER
  // ══════════════════════════════════════════════════════════════════════
  @override
  Future<String> adherer(String numero, String idStructure) =>
      _actionSimple(
        '/insert_subscribe.php',
        {'id_number': numero, 'id_structure': idStructure},
      );

  // ══════════════════════════════════════════════════════════════════════
  // DÉTACHER
  // ══════════════════════════════════════════════════════════════════════
  @override
  Future<String> detacher(String numero, String idStructure) =>
      _actionSimple(
        '/detach_structure.php',
        {'id_number': numero, 'id': idStructure},
      );

  // ── Action générique ────────────────────────────────────────────────
  Future<String> _actionSimple(
      String endpoint,
      Map<String, String> fields,
      ) async
  {
    try {
      final res  = await _post(endpoint, fields);
      final body = res.body.trim();
      debugPrint("$endpoint [${res.statusCode}] : $body");

      if (body.toLowerCase() == 'ok') return 'success';
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final status  = json['status']?.toString()  ?? '';
        final message = json['message']?.toString() ?? '';
        if (status == 'success') return 'success';
        return message.isNotEmpty ? message : 'erreurServeur';
      } catch (_) {}
      return 'erreurServeur';
    } on SocketException {
      throw Exception('pasDeConnexion');
    } catch (e) {
      rethrow;
    }
  }
}
import 'package:eduniger/features/accueil/model/acceuil_model.dart';
import 'package:flutter/cupertino.dart';

import '../../../appstate.dart';
import '../../autheurs/model/author_model.dart' show Author;
import '../../livres/dto/book_dto.dart';
import '../../livres/models/book_model.dart';
import '../../structures/model/structure_model.dart';
import '../repositorie/accueil_repositorie.dart';

class AccueilViewModel {
  final AccueilRepository repositorie;
  final AppState appState;
  final String numero;
  final String version;

  AccueilViewModel({
    required this.repositorie,
    required this.appState,
    required this.numero,
    required this.version,
  }) {
    chargerAccueil();
  }

  // ══════════════════════════════════════════════════════════════════════
  // ÉTAT — mêmes types que ton ancien code
  // ══════════════════════════════════════════════════════════════════════
  List<Book>      _livresRecomandes = [];
  List<Structure> _structures       = [];  // fusion adhérées + recommandées
  List<Author>    _auteurs          = [];

  // Publications locales (assets)
  final List<String> publications = [
    'assets/pub/1.png',
    'assets/pub/2.png',
    'assets/pub/6.png',
  ];

  bool   _isLoading       = false;
  bool   _isActionLoading = false;
  String _errorMessage    = '';
  String _actionMessage   = '';

  // ── Getters ────────────────────────────────────────────────────────────
  List<Book>      get livresRecomandes => _livresRecomandes;
  List<Structure> get structures       => _structures;
  List<Author>    get auteurs          => _auteurs;
  bool            get isLoading        => _isLoading;
  bool            get isActionLoading  => _isActionLoading;
  String          get errorMessage     => _errorMessage;
  String          get actionMessage    => _actionMessage;

  // ══════════════════════════════════════════════════════════════════════
  // CHARGEMENT PRINCIPAL
  // ══════════════════════════════════════════════════════════════════════
  Future<void> chargerAccueil() async {
    // Si déjà en cours de chargement, on ne fait rien
    if (_isLoading) return;

    appState.update(() {
      _isLoading    = true;
      _errorMessage = '';
    });

    try {
      // Vérification de sécurité sur les paramètres
      if (numero.isEmpty) {
        throw Exception("Erreur : Identifiant utilisateur manquant.");
      }
      final AccueilData data =
      await repositorie.chargerAccueil(numero, version);

      _livresRecomandes = data.livresRecomandes;
      _auteurs          = data.auteurs;

      // ── Fusion structures (même logique que ton ancien FutureBuilder) ──
      // On ne refusionne que si la liste est vide
      // (pour préserver les toggles locaux après un setState)
      if (_structures.isEmpty) {
        final adherees = data.structuresAdherees
            .map((s) => s.copyWith(isAdhere: true)).toList();

        final idsAdheres = adherees
            .map((s) => s.id)
            .whereType<int>()
            .toSet();

        final recomFiltrees = data.structuresRecomandees
            .where((s) => !idsAdheres.contains(s.id))
            .map((s) => s.copyWith(isAdhere: false))
            .toList();

        _structures = [...adherees, ...recomFiltrees];
        debugPrint('🏛️ Structures fusionnées : ${_structures.length}');
      }

      appState.update(() { _isLoading = false; });

    } catch (e) {
      debugPrint('❌ Erreur dans AccueilViewModel: $e');
      appState.update(() {
        _isLoading    = false;
        _errorMessage = _mapError(e.toString());
      });
    }
  }

  // ── Refresh (vide les structures pour forcer la re-fusion) ────────────
  Future<void> rafraichir() async {
    appState.update(() { _structures = []; });
    await chargerAccueil();
  }

  // ══════════════════════════════════════════════════════════════════════
  // ACTION : ADHÉRER / DÉTACHER
  // ══════════════════════════════════════════════════════════════════════
  Future<void> toggleStructure(int index) async {
    final Structure s = _structures[index];
    appState.update(() { _isActionLoading = true; });

    try {
      final String result = s.isAdhere
          ? await repositorie.detacher(numero, s.id.toString())
          : await repositorie.adherer(numero,  s.id.toString());

      if (result == 'success') {
        // Mise à jour locale immédiate via copyWith
        // (préserve tous les autres champs de Structure)
        _structures[index] = s.copyWith(isAdhere: !s.isAdhere);
        _actionMessage = s.isAdhere ? 'detache_ok' : 'adhere_ok';
      } else {
        _actionMessage = result;
      }
    } catch (e) {
      _actionMessage = _mapError(e.toString());
    } finally {
      appState.update(() { _isActionLoading = false; });
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // UTILITAIRES
  // ══════════════════════════════════════════════════════════════════════
  void clearActionMessage() {
    _actionMessage = '';
  }

  String _mapError(String error) {
    final e = error.toLowerCase();
    if (e.contains('pasdeconnexion') || e.contains('socketexception') ||
        e.contains('failed host lookup') || e.contains('network')) {
      return 'pasDeConnexion';
    }
    if (e.contains('timeout') || e.contains('trop de temps')) {
      return 'timeout';
    }
    if (e.contains('401') || e.contains('non autorisé')) return '401';
    if (e.contains('404'))                                  return '404';
    if (e.contains('500') || e.contains('serveur'))         return '500';
    return error; // on passe le message brut pour l'affichage
  }
}
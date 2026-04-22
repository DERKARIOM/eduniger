import 'package:flutter/cupertino.dart';

import '../../../appstate.dart';
import '../models/modelCategorie.dart';
import '../repositorie/categorie_repositorie.dart';

class CategorieViewModel extends ChangeNotifier{

  final CategorieRepositorie repositorie;
  final AppState appState;
  late String numero;
  CategorieViewModel(
      this.repositorie,
      this.appState,

      ) {
    numero=appState.numeroUtilisateur;
    _init();
  }

  List<MCategorie> _mcategorie=[];
  List<MCategorie> get mcategorie => _mcategorie;
  String  _errorMessage  = '';
  bool    _isLoading = false;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Future<void> _init() async {
    // Chargement parallèle pour gagner du temps
    await Future.wait([
      chargerCategorie(),
      ]);
  }
  Future<void> chargerCategorie() async {
    _startLoading();
    try {
      _mcategorie = await repositorie.categories(appState.numeroUtilisateur);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }
  void _startLoading() {
    _isLoading    = true;
    _errorMessage = '';
    notifyListeners();
  }
  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  String _mapError(String error) {
    final e = error.toLowerCase();
    if (e.contains('pasdeconnexion') || e.contains('socketexception')) {
      return 'Pas de connexion internet. Vérifiez votre réseau.';
    }
    if (e.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre.';
    }
    if (e.contains('format')) {
      return 'Réponse serveur invalide.';
    }
    return 'Une erreur inattendue est survenue.';
  }


}
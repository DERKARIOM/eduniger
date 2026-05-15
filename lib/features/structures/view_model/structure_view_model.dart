import 'package:eduniger/features/structures/view_model/structure_view_model.dart' as repositorie;
import 'package:flutter/cupertino.dart';

import '../../../appstate.dart';
import '../../livres/models/book_model.dart';
import '../model/structure_model.dart';
import '../repositories/structure_repositorie.dart';

class StructureViewModel extends ChangeNotifier {
  final StructureRepositorie repositorie;
  final AppState appState;
  late String numero;
  StructureViewModel(
      this.repositorie,
      this.appState,){
    numero=appState.numeroUtilisateur;
    _init();
  }

  List<Structure> _structures=[];
  List<Book> _book_structure=[];
  List<Book> get book_structure => _book_structure;

  List<Structure> get structures => _structures;
  String  _errorMessage  = '';
  bool    _isLoading = false;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    // Chargement parallèle pour gagner du temps
    await Future.wait([
      chargerStructures(),
    ]);
  }

  Future<void> chargerStructures() async {
    _startLoading();
    try {
      _structures = await repositorie.structures(appState.numeroUtilisateur);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }
  Future<void> chargerLivreStructure(int id) async {
    _startLoading();
    try {
      _book_structure = await repositorie.livre_structure(appState.numeroUtilisateur,id);
      debugPrint(_book_structure.toString());
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


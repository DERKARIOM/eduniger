import 'dart:io';
import 'package:eduniger/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../localDataBase/sqlflitEduniger.dart';
import '../models/book_model.dart';
import '../models/detaille_book_model.dart';
import '../repositories/book_repository.dart';

class BookViewModel extends ChangeNotifier {
  final BookRepository repositorie;
  final AppState appState;
  final String numero;      // ← ID de l'utilisateur connecté
  final String version;     // ← version de l'app
  BookViewModel({
    required this.repositorie,
    required this.appState,
    required this.numero,
    required this.version,
  }) {
    _init();
  }

  // ══════════════════════════════════════════════════════════════════════
  // ÉTAT
  // ══════════════════════════════════════════════════════════════════════
  List<Book> _livres            = [];
  List<Book> _livresRecomandes  = [];
  List<Book> _livresElectro     = [];
  List<Book> _livresAudio       = [];
  List<DetailleBookModel> _livresTelecharges = [];
  List<Book> _livresEmpruntes   = [];
  List<DetailleBookModel> _livresLocaux      = [];   // ← stockés en local SQLite

  DetailleBookModel? _detailLivre;
  String  _errorMessage        = '';
  bool    _isLoading           = false;
  bool    _isLoadingDetail     = false;
  bool    _isDownloading       = false;
  double  _downloadProgress    = 0.0;  // 0.0 → 1.0
  String  _actionMessage       = '';   // retour des actions like/vue/etc.

  // ── Getters ────────────────────────────────────────────────────────
  List<Book>    get livres            => _livres;
  List<Book>    get livresRecomandes  => _livresRecomandes;
  List<Book>    get livresElectro     => _livresElectro;
  List<Book>    get livresAudio       => _livresAudio;
  List<DetailleBookModel>    get livresTelecharges => _livresTelecharges;
  List<Book>    get livresEmpruntes   => _livresEmpruntes;
  List<DetailleBookModel>    get livresLocaux      => _livresLocaux;
  DetailleBookModel? get detailLivre       => _detailLivre;
  String             get errorMessage      => _errorMessage;
  bool               get isLoading         => _isLoading;
  bool               get isLoadingDetail   => _isLoadingDetail;
  bool               get isDownloading     => _isDownloading;
  double             get downloadProgress  => _downloadProgress;
  String             get actionMessage     => _actionMessage;

  // ══════════════════════════════════════════════════════════════════════
  // INITIALISATION
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _init() async {
    // Chargement parallèle pour gagner du temps
    await Future.wait([
      chargerLivres(),
      //chargerRecomandes(),
      chargerLivresLocaux(),   // ← livres hors-ligne dès le démarrage
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════
  // CHARGEMENT DES LISTES
  // ══════════════════════════════════════════════════════════════════════
  Future<void> chargerLivres() async {
    _startLoading();
    try {
      _livres = await repositorie.livres(appState.numeroUtilisateur);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }
/*
  Future<void> chargerRecomandes() async {
    try {
      _livresRecomandes = await repositorie.livreRecomander(numero, version);
      notifyListeners();
    } catch (e) {
      debugPrint("Recomandés : ${e.toString()}");
    }
  }
*/
  Future<void> chargerElectroniques() async {
    _startLoading();
    try {
      _livresElectro = await repositorie.livreElectronique(numero);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  Future<void> chargerAudio() async {
    _startLoading();
    try {
      _livresAudio = await repositorie.livreAudio(numero);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  Future<void> chargerEmpruntes() async {
    _startLoading();
    try {
      _livresEmpruntes = await repositorie.livreEmprunter(numero);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // DÉTAIL D'UN LIVRE
  // ══════════════════════════════════════════════════════════════════════
  Future<void> chargerDetail(String idBook) async {
    _isLoadingDetail = true;
    _errorMessage    = '';
    notifyListeners();
    try {
      _detailLivre = await repositorie.detail(numero, idBook);
      // On enregistre automatiquement la vue
      await enregistrerVue(idBook);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // ACTIONS (like / dislike / vue / abonner / commenter)
  // ══════════════════════════════════════════════════════════════════════
  Future<void> enregistrerVue(String idBook) async {
    try {
      await repositorie.vue(numero, idBook);
    } catch (e) {
      debugPrint("Vue non enregistrée : $e");
    }
  }

  Future<void> likerLivre(String idBook) async {
    try {
      final result = await repositorie.like(numero, idBook);
      _actionMessage = result == 'success' ? 'like_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  Future<void> dislikerLivre(String idBook) async {
    try {
      final result = await repositorie.dislike(numero, idBook);
      _actionMessage = result == 'success' ? 'dislike_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  Future<void> abonnerLivre(String idBook) async {
    try {
      final result = await repositorie.abonner(numero, idBook);
      _actionMessage = result == 'success' ? 'abonne_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  Future<void> commenterLivre(String idBook, String texte) async {
    if (texte.trim().isEmpty) {
      _errorMessage = 'Le commentaire ne peut pas être vide.';
      notifyListeners();
      return;
    }
    try {
      final result = await repositorie.comment(numero, idBook, texte.trim());
      _actionMessage = result == 'success' ? 'comment_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // TÉLÉCHARGEMENT & STOCKAGE LOCAL
  // ══════════════════════════════════════════════════════════════════════

  /// Télécharge le fichier du livre et le stocke localement
  Future<void> telechargerLivre(DetailleBookModel book) async {
    // Vérifier si déjà téléchargé
    final dejaTelechage = await DatabaseHelper.instance
        .isBookTelecharge(book.id, numero);
    if (dejaTelechage) {
      _actionMessage = 'deja_telecharge';
      notifyListeners();
      return;
    }

    _isDownloading    = true;
    _downloadProgress = 0.0;
    _errorMessage     = '';
    notifyListeners();

    try {
      // 1. Récupérer le dossier local de l'app
      final dir        = await getApplicationDocumentsDirectory();
      final extension  = book.est_electronique == true ? 'pdf' : book.est_audio==true ? 'mp3' : 'null';
      final cheminLocal= '${dir.path}/livres/${book.id}.$extension';

      // Créer le dossier si nécessaire
      await Directory('${dir.path}/livres').create(recursive: true);

      // 2. Télécharger avec suivi de progression
      final client   = http.Client();
      final request  = http.Request('GET', Uri.parse(book.fichier));
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? 0;
      int   received   = 0;
      final file       = File(cheminLocal);
      final sink       = file.openWrite();

      await response.stream.map((chunk) {
        received += chunk.length;
        if (totalBytes > 0) {
          _downloadProgress = received / totalBytes;
          notifyListeners();
        }
        return chunk;
      }).pipe(sink);

      await sink.close();
      client.close();

      // 3. Sauvegarder en base locale SQLite
      await DatabaseHelper.instance.saveBookTelecharge(book, cheminLocal, numero,);

      // 4. Rafraîchir la liste locale
      await chargerLivresLocaux();

      _actionMessage    = 'telecharge_ok';
      _downloadProgress = 1.0;

    } catch (e) {
      _errorMessage = "Erreur lors du téléchargement : ${e.toString()}";
      debugPrint("❌ Téléchargement échoué : $e");
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Charger les livres stockés localement (hors-ligne)
  Future<void> chargerLivresLocaux() async {
    try {
      _livresLocaux = await DatabaseHelper.instance.getBooksTelecharges( numero);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur chargement local : $e");
    }
  }

  /// Supprimer un livre téléchargé (fichier + base locale)
  Future<void> supprimerLivreLocal(DetailleBookModel book,String numero) async {
    try {
      // 1. Supprimer le fichier physique
      final file = File(book.fichier);
      if (await file.exists()) {
        await file.delete();
        debugPrint("🗑️ Fichier supprimé : ${book.fichier}");
      }
      // 2. Supprimer de la base SQLite
      await DatabaseHelper.instance.deleteBookTelecharge(book.id, numero);
      // 3. Rafraîchir la liste
      await chargerLivresLocaux();

    } catch (e) {
      _errorMessage = "Erreur lors de la suppression : ${e.toString()}";
      notifyListeners();
    }
  }

  /// Vérifier si un livre est disponible hors-ligne
  Future<bool> estDisponibleHorsLigne(String idBook) async {
    return DatabaseHelper.instance.isBookTelecharge(idBook, numero);
  }

  // ══════════════════════════════════════════════════════════════════════
  // UTILITAIRES PRIVÉS
  // ══════════════════════════════════════════════════════════════════════
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

  void clearActionMessage() {
    _actionMessage = '';
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

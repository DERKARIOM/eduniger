import 'package:eduniger/features/livres/repositories/postmant_book_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'features/accueil/repositorie/pastmant_acceuil_repositorie.dart';
import 'features/accueil/view_model/accueil_view_model.dart';
import 'features/livres/view_models/book_view_model.dart';
import 'features/notification/view_model/notification_view_model.dart';
import 'features/utilisateurs/repositories/postmant_user_repositore.dart';
import 'features/utilisateurs/view_models/user_view_model.dart';
import 'localDataBase/sqlflitEduniger.dart';
// Importez votre helper de base de données (adaptez le nom selon votre projet)
// import 'core/database/database_helper.dart';
/*
class AppState extends ChangeNotifier {
  static final AppState _singleton = AppState._internal();

  AppState._internal() {
    final repo = PostmantUserRepositoie();
    _utilisa = UserViewModel(repo, this);
    _notifVM     = NotificationViewModel(this);
    // On lance la vérification du stockage local au démarrage
    // final livres =PostmantBookRepositorie();
    //_livres = BookViewModel(repositorie: livres, numero: numeroUtilisateur, version: '3.1.3');
    chargerSessionLocale();
  }

  factory AppState() => _singleton;

  // ── État global ──────────────────────────────────────────────────────
  bool estConnecter = false;
  String _numeroUtilisateur = '';
  String _version = '';
  static const String _baseUrlCover = 'https://eduniger.com/admin-api/storage/app/private/structures/';
  static const String _baseUrlProfile = 'https://eduniger.com/ressources/profile/';

  ThemeMode? themeChoisie;
  bool isInitialized = false; // Pour savoir si le check local est fini

  // ── ViewModels ──────────────────────────────────────────────────────
  late UserViewModel _utilisa;
  UserViewModel get utilisa => _utilisa;
  late NotificationViewModel       _notifVM;
   BookViewModel? _livres;
  BookViewModel? get livres => _livres;
  AccueilViewModel? _accueilVM;
  NotificationViewModel       get notifVM    => _notifVM;
  AccueilViewModel get accueilVM => _accueilVM!;
  String  get numeroUtilisateur => _numeroUtilisateur;
  String get baseUrlCover => _baseUrlCover;
  String get baseUrlProfile => _baseUrlProfile;
  String get version => _version;


  Future<void> setVersion(String version) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version; // Retourne "3.1.3"

  }

  Future<void> setNumeroUtilisateur() async {
    Object? userLocal = await DatabaseHelper.instance.getIdNumber();
    _numeroUtilisateur=userLocal.toString();
  }
  // ── Nouvelle méthode pour charger l'utilisateur local ────────────────
  Future<void> chargerSessionLocale() async {
    try {
      // 1. Récupérer l'utilisateur depuis la DB locale
      // Note: Assurez-vous d'avoir une méthode 'getUser' dans votre DatabaseHelper
      final userLocal = await DatabaseHelper.instance.getIdNumber();

      if (userLocal != null) {
        // 2. Si on trouve un utilisateur, on initialise l'accueil
        // On suppose que la version est récupérée ou codée en dur
        String version = "3.1.3";

        initialiserAccueilVM(userLocal.toString(), version);

        // 3. Mettre à jour l'état
        estConnecter = true;
      }
    } catch (e) {
      debugPrint("Erreur chargement session locale: $e");
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

void initialiserLivresVM(String numeroUtilisateur, String version) {
    _livres = BookViewModel(
      repositorie: PostmantBookRepositorie(),
      appState: this,
      numero: numeroUtilisateur ,
      version: version,
    );
    notifyListeners();
}
  void initialiserAccueilVM(String numero, String version) {
    _accueilVM = AccueilViewModel(
      repositorie: PostmantAccueilRepository(),
      appState: this,
      numero: numero,
      version: version,
    );
    estConnecter = true;
    notifyListeners();
  }


  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // Méthode de déconnexion pour nettoyer le local
  Future<void> deconnexion() async {
    await DatabaseHelper.instance.logout(); // À implémenter dans votre DB helper
    estConnecter = false;
    _accueilVM = null;
    notifyListeners();
  }
}
*/
class AppState extends ChangeNotifier {
  static final AppState _singleton = AppState._internal();
  AppState._internal();
  factory AppState() => _singleton;

  // ── État global uniquement (pas de ViewModels ici) ───────────────────
  bool      estConnecter        = false;
  bool      isInitialized       = false;
  String    _numeroUtilisateur  = '';
  String    _version            = '';
  ThemeMode? themeChoisie;

  static const String baseUrlCover =
      'https://eduniger.com/admin-api/storage/app/private/structures/';
  static const String baseUrlProfile =
      'https://eduniger.com/ressources/profile/';

  String get numeroUtilisateur => _numeroUtilisateur;
  String get version           => _version;

  // ── Chargement session locale ─────────────────────────────────────────
  Future<void> chargerSessionLocale() async {
    try {
      final userLocal = await DatabaseHelper.instance.getIdNumber();
      if (userLocal != null) {
        _numeroUtilisateur = userLocal.toString();
        final info = await PackageInfo.fromPlatform();
        _version     = info.version;
        estConnecter = true;
      }
    } catch (e) {
      debugPrint("Erreur session locale : $e");
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  // ── Connexion réussie (appelée par UserViewModel) ─────────────────────
  void onConnexionReussie(String numero, String version) {
    _numeroUtilisateur = numero;
    _version           = version;
    estConnecter       = true;
    notifyListeners();
  }

  // ── Déconnexion ───────────────────────────────────────────────────────
  Future<void> deconnexion() async {
    await DatabaseHelper.instance.logout();
    _numeroUtilisateur = '';
    estConnecter       = false;
    notifyListeners();
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}
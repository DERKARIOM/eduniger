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
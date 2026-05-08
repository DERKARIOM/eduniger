import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:eduniger/appstate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../localDataBase/sqlflitEduniger.dart';
import '../models/user_model.dart';
import '../repositories/user_repositorie.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepositorie repositorie;
  final AppState appState;

  UserViewModel(this.repositorie, this.appState) {
    _init();
  }

  // ══════════════════════════════════════════════════════════════════════
  // ÉTAT
  // ══════════════════════════════════════════════════════════════════════
  UserModel? _currentUser;
  String  _countryCode       = '+227';
  String  _errorMessage      = '';
  bool    _isLoading         = false;
  bool    _isPasswordVisible = false;
  String  _firebaseToken     = '';
  String  _appVersion        = '';
  String  _idUser            = '';

  // ── Flags de navigation (un par action) ───────────────────────────────
  bool _loginSuccess    = false;
  bool _registerSuccess = false;
  bool _changeSuccess   = false;

  // ── Inscription ───────────────────────────────────────────────────────
  String _selectedProfession = 'Sélectionnez votre profession';
  final List<String> professions = [
    'Sélectionnez votre profession',
    'Élève', 'Étudiant', 'Enseignant', 'Professionnel', 'Autre',
  ];

  // ══════════════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════════════
  UserModel? get currentUser       => _currentUser;
  String     get countryCode       => _countryCode;
  String     get errorMessage      => _errorMessage;
  bool       get isLoading         => _isLoading;
  bool       get isPasswordVisible => _isPasswordVisible;
  String     get appVersion        => _appVersion;
  String     get firebaseToken     => _firebaseToken;
  String     get idUser            => _idUser;
  bool       get loginSuccess      => _loginSuccess;
  bool       get registerSuccess   => _registerSuccess;
  bool       get changeSuccess     => _changeSuccess;
  String     get selectedProfession => _selectedProfession;

  // ══════════════════════════════════════════════════════════════════════
  // INITIALISATION
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _init() async {
    _firebaseToken = await _getFirebaseToken();
    _appVersion    = await _getAppVersion();
    appState.update((){});
    //appState.initialiserBookVM(_currentUser!.numero, _appVersion);
    //notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════
  // ACTIONS UI
  // ══════════════════════════════════════════════════════════════════════
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    appState.update((){});
    notifyListeners();
  }

  void setCountryCode(String code) {
    _countryCode = code;
    appState.update((){});
    notifyListeners();
  }

  void selectProfession(String profession) {
    _selectedProfession = profession;
    appState.update((){});
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    appState.update((){});
    notifyListeners();
  }

  // ── Reset flags (appelés après navigation) ────────────────────────────
  void resetLoginSuccess()    { _loginSuccess    = false; }
  void resetRegisterSuccess() { _registerSuccess = false; }
  void resetChangeSuccess()   { _changeSuccess   = false; }

  // ══════════════════════════════════════════════════════════════════════
  // CONNEXION
  // ══════════════════════════════════════════════════════════════════════
  Future<void> login(String numero, String password) async
  {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    // 1. Validation via UserModel
    try {
      UserModel(
        idantifiant  : 0,   nom: 'temp', prenom: 'temp',
        numero       : numero,
        mail         : 'temp@temp.com',
        mot_de_passe : password,
        profession   : 'temp',
      ).se_connecter(numero, password);      // ← méthode métier de UserModel
    } on Exception catch (e) {
      appState.update((){});
      _setError(e.toString().replaceAll('Exception: ', ''));
      appState.update((){});
      return;
    }
    _firebaseToken = (await messaging.getToken())!;
    //print("FCM Token: $_firebaseToken");
    appState.update((){
      _startLoading();
      _loginSuccess = false;

    });
    print("${numero} ${password} ${_firebaseToken} ${_appVersion}");

    try {
      final user = await repositorie.seconecter(
        numero, _hashPassword(password), _firebaseToken, _appVersion,
      );
      await _saveUserLocally(user,_firebaseToken ,numero);
      _currentUser  = user;
      _loginSuccess = true;
      //appState.initialiserAccueilVM(user.numero, _appVersion);
      appState.onConnexionReussie(user.numero, _appVersion);
      appState.update((){});
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      appState.update((){});
    } finally {
      _stopLoading();
      notifyListeners();
     // appState.update((){});
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // INSCRIPTION
  // ══════════════════════════════════════════════════════════════════════
  Future<void> register(
      String nom,     String prenom,   String numero,
      String email,   String password, String confirmPassword, String selectedProfession,String token
      ) async
  {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    // 1. Validation via UserModel
    try {
      UserModel(
        idantifiant  : 0,
        nom          : nom,
        prenom       : prenom,
        numero       : numero,
        mail         : email,
        mot_de_passe : password,
        profession   : _selectedProfession == 'Sélectionnez votre profession'
            ? '' : _selectedProfession,

      ).creer_compte(            // ← méthode métier de UserModel
        numero, email, nom, prenom, password, confirmPassword,
        _selectedProfession == 'Sélectionnez votre profession'
            ? '' : _selectedProfession,
      );
    } on Exception catch (e) {

      _setError(e.toString().replaceAll('Exception: ', ''));
      return;
    }
    _startLoading();
    appState.update((){

      _registerSuccess = false;
    });
    print("${nom} ${prenom} ${numero} ${email} ${password} ${_selectedProfession}");
    try {
      _firebaseToken = (await messaging.getToken())!;
      print("FCM Token: $_firebaseToken");
      print("${nom} ${prenom} ${numero} ${email} ${_hashPassword(password)} ${_getProfessionCode(_selectedProfession)} ${_appVersion}");
      final result = await repositorie.creer_compte(
        numero, email, nom, prenom,
        _hashPassword(password),
        _getProfessionCode(_selectedProfession),
        _appVersion,
          _firebaseToken
      );
      // ← résultat traité séparément pour register
      _handleRegisterResult(result);
      appState.update((){});
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      appState.update((){});
    } finally {
      _stopLoading();

    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // CHANGEMENT MOT DE PASSE
  // ══════════════════════════════════════════════════════════════════════
  Future<void> changerMotDePasse(
      String numero, String email,
      String password, String confirmPassword,
      ) async
  {

    // 1. Validation via UserModel
    try {
      UserModel(
        idantifiant  : 0,   nom: 'temp', prenom: 'temp',
        numero       : numero,
        mail         : email,
        mot_de_passe : password,
        profession   : 'temp',
      ).changer_mot_de_passe(   // ← méthode métier de UserModel
        numero, email, password, confirmPassword,
      );
    } on Exception catch (e) {

      _setError(e.toString().replaceAll('Exception: ', ''));

      return;
    }
    _startLoading();
    appState.update((){

      _changeSuccess = false;
    });

    try {
      final result = await repositorie.changer_mot_de_passe(
        numero, email, _hashPassword(password),
      );
      // ← résultat traité séparément pour changePassword
      _handleChangePasswordResult(result);
      appState.update((){});
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      appState.update((){});
      notifyListeners();
    } finally {
      _stopLoading();
     // appState.update((){});
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // HANDLERS DE RÉSULTATS (séparés pour éviter les conflits de flags)
  // ══════════════════════════════════════════════════════════════════════
  void _handleRegisterResult(String result) {
    switch (result) {
      case 'success':
        _registerSuccess = true;         // ← UNIQUEMENT registerSuccess
        break;
      case 'existingAccount':
        _errorMessage = 'Ce numéro de téléphone est déjà utilisé.';
        break;
      case 'existingEmail':
        _errorMessage = 'Cet email est déjà utilisé.';
        break;
      case 'champVide':
        _errorMessage = 'Veuillez remplir tous les champs.';
        break;
      default:
        _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  void _handleChangePasswordResult(String result) {
    switch (result) {
      case 'success':
        _changeSuccess = true;           // ← UNIQUEMENT changeSuccess
        break;
      case 'noFoundIdNumberOrEmail':
        _errorMessage = "Le numéro ou l'email est incorrect.";
        break;
      case 'erreurServeur':
        _errorMessage = 'Erreur serveur. Veuillez réessayer.';
        break;
      default:
        _errorMessage = 'Une erreur inattendue est survenue.';
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // SAUVEGARDE LOCALE
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _saveUserLocally(UserModel user, String token ,String numero) async {
    try {
      await DatabaseHelper.instance.saveUser(user, token);
      debugPrint("✅ Utilisateur sauvegardé");
    } catch (e) {
      debugPrint("⚠️ Erreur SQL saveUser : $e");
    }
    try {
      await DatabaseHelper.instance.saveIdNumber(numero);
      final id = await DatabaseHelper.instance.getIdNumber();
      final toke=await DatabaseHelper.instance.gettoken();
      _idUser = id.toString();
      debugPrint("✅ ID récupéré : $_idUser");
      debugPrint("✅ tocken  récupére : $toke");
    } catch (e) {
      debugPrint("⚠️ Erreur SQL saveIdNumber : $e");
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // UTILITAIRES PRIVÉS
  // ══════════════════════════════════════════════════════════════════════
  void _startLoading() {
    _isLoading    = true;
    _errorMessage = '';
    appState.update((){});
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    appState.update((){});
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    appState.update((){});
    notifyListeners();
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  String _getProfessionCode(String profession) {
    const Map<String, String> codes = {
      'Élève'        : '1',
      'Étudiant'     : '2',
      'Enseignant'   : '3',
      'Professionnel': '4',
      'Autre'        : '5',
    };
    return codes[profession] ?? '5';
  }

  Future<String> _getAppVersion() async {
    return (await PackageInfo.fromPlatform()).version;
  }

  Future<String> _getFirebaseToken() async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? 'token_default';
    } catch (_) {
      return 'token_error';
    }
  }

  String _mapError(String error) {
    final e = error.toLowerCase();
    if (e.contains('mot de passe incorrect')) return "Le mot de passe est incorrect.";
    if (e.contains('compte inexistant'))      return "Ce compte n'existe pas.";
    if (e.contains('account locked'))         return "Compte temporairement bloqué. Contactez le support.";
    if (e.contains('update required'))        return "Veuillez mettre à jour votre application.";
    if (e.contains('pasdeconnexion') ||
        e.contains('socketexception'))        return "Pas de connexion internet. Vérifiez votre réseau.";
    if (e.contains('timeout'))                return "Le serveur met trop de temps à répondre.";
    return "Une erreur inattendue est survenue. Veuillez réessayer.";
  }
}
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../appstate.dart';
import '../model/notification_model.dart';
import '../service/badje_service.dart';
import '../service/notification_service.dart';
import 'package:flutter/material.dart';
class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int    _nonLues   = 0;
  bool   _isLoading = false;
  bool   _autorise  = false;

  List<NotificationModel> get notifications => _notifications;
  int    get nonLues   => _nonLues;
  bool   get isLoading => _isLoading;
  bool   get autorise  => _autorise;

  NotificationViewModel() {
    NotificationService.instance.onNouvelleNotification = chargerNotifications;
  }

  // ── Appelé après login avec le numéro ──────────────────────────────────
  Future<void> initialiserApresLogin(String numero) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Définir l'utilisateur dans le service
      await NotificationService.instance.definirUtilisateur(numero);

      // 2. Demander permission
      _autorise = await NotificationService.instance.demanderAutorisation();

      if (_autorise) {
        final token = await NotificationService.instance.getToken();
        if (token.isNotEmpty) await _envoyerToken(numero, token);
        NotificationService.instance.ecouterRenouvellementToken(
              (t) => _envoyerToken(numero, t),
        );
      }

      // 3. Charger les notifs existantes depuis SQLite
      await chargerNotifications();
      await BadgeService.instance.mettreAJour(_nonLues);

    } catch (e) {
      debugPrint('⚠️ Init notifs : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> chargerNotifications() async {
    _notifications = await NotificationService.instance.chargerNotifications();
    _nonLues       = await NotificationService.instance.getNombreNonLues();
    notifyListeners();
  }

  Future<void> marquerCommeLue(String id) async {
    await NotificationService.instance.marquerCommeLue(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].estLue) {
      _notifications[idx].estLue = true;
      _nonLues = (_nonLues - 1).clamp(0, 999);
      notifyListeners();
    }
  }

  Future<void> toutMarquerLues() async {
    await NotificationService.instance.toutMarquerLues();
    for (final n in _notifications) { n.estLue = true; }
    _nonLues = 0;
    await BadgeService.instance.effacer();
    notifyListeners();
  }

  Future<void> supprimer(String id) async {
    await NotificationService.instance.supprimerNotification(id);
    final avantEstLue = _notifications.firstWhere(
          (n) => n.id == id, orElse: () => _notifications.first,
    ).estLue;
    _notifications.removeWhere((n) => n.id == id);
    if (!avantEstLue) _nonLues = (_nonLues - 1).clamp(0, 999);
    notifyListeners();
  }

  Future<void> toutEffacer() async {
    await NotificationService.instance.toutEffacer();
    _notifications.clear();
    _nonLues = 0;
    notifyListeners();
  }

  Future<void> _envoyerToken(String numero, String token) async {
    try {
      final req = http.MultipartRequest(
        'POST', Uri.parse('https://api.eduniger.com/update_token.php'),
      );
      req.fields['id_number'] = numero;
      req.fields['token']     = token;
      final res = await http.Response.fromStream(await req.send());
      debugPrint('📤 Token [${res.statusCode}]');
    } catch (e) {
      debugPrint('⚠️ Token : $e');
    }
  }
}
/*
class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications   = [];
  bool                    _isLoading        = false;
  bool                    _autorise         = false;
  String                  _erreur           = '';

  List<NotificationModel> get notifications    => _notifications;
  bool                    get isLoading        => _isLoading;
  bool                    get autorise         => _autorise;
  String                  get erreur           => _erreur;
  int                     get nombreNonLues    =>
      _notifications.where((n) => !n.estLue).length;

  NotificationViewModel() {
    // Écouter les nouvelles notifications en temps réel
    NotificationService.instance.onNouvelleNotification = () {
      chargerNotifications();
    };
  }

  // ── Initialisation après login ─────────────────────────────────────────
  Future<void> initialiserNotifications(String numero) async {
    _isLoading = true;
    notifyListeners();
    try {
      final autorise = await NotificationService.instance.demanderAutorisation();
      _autorise = autorise;
      if (autorise) {
        final token = await NotificationService.instance.getToken();
        if (token.isNotEmpty) await _envoyerToken(numero, token);
        NotificationService.instance.ecouterRenouvellementToken(
              (t) => _envoyerToken(numero, t),
        );
      }
      await chargerNotifications();
    } catch (e) {
      _erreur = 'Erreur : ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Charger les notifications depuis le stockage local ─────────────────
  Future<void> chargerNotifications() async {
    _notifications = await NotificationService.instance.chargerNotifications();
    notifyListeners();
  }

  Future<void> marquerCommeLue(String id) async {
    await NotificationService.instance.marquerCommeLue(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].estLue = true;
      notifyListeners();
    }
  }

  Future<void> toutMarquerLues() async {
    await NotificationService.instance.toutMarquerLues();
    for (final n in _notifications) { n.estLue = true; }
    notifyListeners();
  }

  Future<void> supprimer(String id) async {
    await NotificationService.instance.supprimerNotification(id);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> toutEffacer() async {
    await NotificationService.instance.toutEffacer();
    _notifications.clear();
    notifyListeners();
  }

  // ── Envoi token au serveur ─────────────────────────────────────────────
  Future<void> _envoyerToken(String numero, String token) async {
    try {
      final req = http.MultipartRequest(
        'POST', Uri.parse('https://api.eduniger.com/update_token.php'),
      );
      req.fields['id_number'] = numero;
      req.fields['token']     = token;
      final res = await http.Response.fromStream(await req.send());
      debugPrint('📤 Token [${res.statusCode}]');
    } catch (e) {
      debugPrint('⚠️ Token envoi : $e');
    }
  }
}
*/

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../appstate.dart';
import '../service/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final AppState appState;

  NotificationViewModel(this.appState);

  bool   _autorisationAccordee = false;
  bool   _isLoading            = false;
  String _messageErreur        = '';

  bool   get autorisationAccordee => _autorisationAccordee;
  bool   get isLoading            => _isLoading;
  String get messageErreur        => _messageErreur;

  // ── Appelé après login ET après création de compte ───────────────────
  Future<void> initialiserNotifications(String numero) async {
    appState.update(() { _isLoading = true; });

    try {
      // 1. Demander l'autorisation
      final bool autorise =
      await NotificationService.instance.demanderAutorisation();
      _autorisationAccordee = autorise;

      if (autorise) {
        // 2. Récupérer le token FCM
        final String token =
        await NotificationService.instance.getToken();

        // 3. Envoyer le token au serveur si nécessaire
        if (token.isNotEmpty) {
          await _envoyerTokenAuServeur(numero, token);
        }

        // 4. Écouter le renouvellement du token
        NotificationService.instance.ecouterRenouvellementToken(
              (newToken) => _envoyerTokenAuServeur(numero, newToken),
        );
      }
    } catch (e) {
      _messageErreur = 'Erreur notifications : ${e.toString()}';
      debugPrint(_messageErreur);
    } finally {
      appState.update(() { _isLoading = false; });
    }
  }

  // ── Envoyer le token FCM au serveur ───────────────────────────────────
  Future<void> _envoyerTokenAuServeur(
      String numero, String token) async {
    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.eduniger.com/update_token.php'),
      );
      req.fields['id_number'] = numero;
      req.fields['token']     = token;
      final res = await http.Response.fromStream(await req.send());
      debugPrint('📤 Token envoyé [${res.statusCode}] : ${res.body}');
    } catch (e) {
      debugPrint('⚠️ Erreur envoi token : $e');
      // Non bloquant : on ne stoppe pas l'utilisateur
    }
  }
}
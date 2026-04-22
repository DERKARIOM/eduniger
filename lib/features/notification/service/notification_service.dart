// notification_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ── Handler background (obligatoire top-level function) ──────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Notification background : ${message.notification?.title}');
  await NotificationService.instance.afficherNotificationLocale(message);
}

class NotificationService {
  // ── Singleton ─────────────────────────────────────────────────────────
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging          _messaging    = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
  FlutterLocalNotificationsPlugin();

  // Canal Android (doit correspondre au canal déclaré dans AndroidManifest)
  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    'eduniger_canal_principal',       // id
    'Notifications EduNiger',         // nom visible
    description : 'Notifications de l\'application EduNiger',
    importance  : Importance.high,
  );

  // ── Initialisation complète ───────────────────────────────────────────
  Future<void> initialiser() async {
    // 1. Créer le canal Android
    await _localNotif.resolvePlatformSpecificImplementation;
    AndroidFlutterLocalNotificationsPlugin()
        ?.createNotificationChannel(_canal);

    // 2. Initialiser flutter_local_notifications
    const initAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher'); // ← ton icône d'app
    const initIOS = DarwinInitializationSettings(
      requestAlertPermission  : false, // géré manuellement après login
      requestBadgePermission  : false,
      requestSoundPermission  : false,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: initAndroid, iOS: initIOS),
      onDidReceiveNotificationResponse: _onNotificationTappee,
    );

    // 3. Handler background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Notification reçue en foreground
    FirebaseMessaging.onMessage.listen(_onMessageForeground);

    // 5. Notification tapée depuis background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOuverte);

    // 6. Vérifier si app ouverte depuis notification (app killed)
    final RemoteMessage? initial =
    await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 App ouverte depuis notification : ${initial.data}');
      _traiterDonnees(initial.data);
    }

    debugPrint('✅ NotificationService initialisé');
  }

  // ── Demande d'autorisation (appelée après login/register) ────────────
  Future<bool> demanderAutorisation() async {
    final NotificationSettings settings =
    await _messaging.requestPermission(
      alert       : true,
      badge       : true,
      sound       : true,
      provisional : false,   // iOS : false = demande réelle
    );

    final bool autorise =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint(autorise
        ? '✅ Notifications autorisées'
        : '❌ Notifications refusées');

    return autorise;
  }

  // ── Récupérer le token FCM ────────────────────────────────────────────
  Future<String> getToken() async {
    try {
      final String? token = await _messaging.getToken();
      debugPrint('🔑 FCM Token : $token');
      return token ?? '';
    } catch (e) {
      debugPrint('⚠️ Erreur getToken : $e');
      return '';
    }
  }

  // ── Écouter le renouvellement de token ───────────────────────────────
  void ecouterRenouvellementToken(Function(String) onNewToken) {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token renouvelé : $newToken');
      onNewToken(newToken);
    });
  }

  // ── Afficher une notification locale ─────────────────────────────────
  Future<void> afficherNotificationLocale(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription : _canal.description,
          importance         : Importance.high,
          priority           : Priority.high,
          icon               : '@mipmap/ic_launcher',
          // Payload pour savoir où naviguer au tap
          ticker             : notification.title,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert : true,
          presentBadge : true,
          presentSound : true,
        ),
      ),
      // Données pour la navigation au tap
      payload: jsonEncode(message.data),
    );
  }

  // ── Handlers privés ───────────────────────────────────────────────────

  // Notification reçue quand l'app est OUVERTE
  void _onMessageForeground(RemoteMessage message) {
    debugPrint('📩 Foreground : ${message.notification?.title}');
    afficherNotificationLocale(message);
  }

  // Notification tapée depuis BACKGROUND
  void _onMessageOuverte(RemoteMessage message) {
    debugPrint('👆 Notification tapée (background) : ${message.data}');
    _traiterDonnees(message.data);
  }

  // Tap sur notification locale (flutter_local_notifications)
  void _onNotificationTappee(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final Map<String, dynamic> data =
      jsonDecode(response.payload!) as Map<String, dynamic>;
      debugPrint('👆 Notification locale tapée : $data');
      _traiterDonnees(data);
    } catch (e) {
      debugPrint('⚠️ Erreur payload : $e');
    }
  }

  // ── Navigation selon les données de la notification ───────────────────
  void _traiterDonnees(Map<String, dynamic> data) {
    final String type   = data['type']?.toString()    ?? '';
    final String idBook = data['id_book']?.toString() ?? '';
    final String idUser = data['id_user']?.toString() ?? '';

    debugPrint('📌 Type : $type | id_book : $idBook');

    // On stocke les données pour que la View navigue au bon moment
    _navigationEnAttente = data;
  }

  // Données de navigation en attente (lues par la View)
  Map<String, dynamic>? _navigationEnAttente;
  Map<String, dynamic>? get navigationEnAttente => _navigationEnAttente;
  void clearNavigation() { _navigationEnAttente = null; }
}
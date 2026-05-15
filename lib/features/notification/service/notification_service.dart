// notification_service.dart
import 'dart:convert';
import 'package:eduniger/appstate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../localDataBase/sqlflitEduniger.dart';
import '../model/notification_model.dart';
import 'badje_service.dart';
import 'navigation_service.dart';
// ── Handler background (obligatoire top-level function) ──────────────────
/*
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.instance._sauvegarderNotification(message);
  debugPrint('📩 Background : ${message.notification?.title}');
}

// ────────────────────────────────────────────────────────────────────────────
class NotificationService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging               _messaging  = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  static const String _clePrefs = 'notifications_locales';

  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    'eduniger_canal_principal',
    'Notifications EduNiger',
    description : 'Notifications de l\'application EduNiger',
    importance  : Importance.high,
  );

  // Callback notifiant le ViewModel quand une nouvelle notif arrive
  VoidCallback? onNouvelleNotification;

  // ── INITIALISATION ────────────────────────────────────────────────────────
  Future<void> initialiser() async {

    // 1. ✅ CORRECTION : résolution correcte du plugin Android

    await _localNotif.resolvePlatformSpecificImplementation;
    AndroidFlutterLocalNotificationsPlugin()?.createNotificationChannel(_canal);

    // 2. Init flutter_local_notifications
    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initIOS = DarwinInitializationSettings(
      requestAlertPermission : false,
      requestBadgePermission : false,
      requestSoundPermission : false,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: initAndroid, iOS: initIOS),
      onDidReceiveNotificationResponse         : _onNotificationLocaleTappee,
      onDidReceiveBackgroundNotificationResponse: _onNotificationLocaleTappee,
    );

    // 3. Handler background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Foreground
    FirebaseMessaging.onMessage.listen(_onMessageForeground);

    // 5. Tap depuis background (app ouverte)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOuvert);

    // 6. App ouverte depuis notification (app killed)
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) {
      await _sauvegarderNotification(initial);
      // Délai pour laisser le temps au widget de s'initialiser
      Future.delayed(const Duration(milliseconds: 500), () {
        _traiterNavigation(initial.data);
      });
    }

    debugPrint('✅ NotificationService initialisé');
  }

  // ── PERMISSION ────────────────────────────────────────────────────────────
  Future<bool> demanderAutorisation() async {
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<AuthorizationStatus> statutAutorisation() async {
    final s = await _messaging.getNotificationSettings();
    return s.authorizationStatus;
  }

  // ── TOKEN FCM ─────────────────────────────────────────────────────────────
  Future<String> getToken() async {
    try {
      return await _messaging.getToken() ?? '';
    } catch (e) {
      debugPrint('⚠️ getToken : $e');
      return '';
    }
  }

  void ecouterRenouvellementToken(Function(String) onNew) =>
      _messaging.onTokenRefresh.listen(onNew);

  // ── AFFICHER NOTIFICATION LOCALE ─────────────────────────────────────────
  Future<void> _afficherNotificationManuelle(RemoteMessage msg, String? title, String? body) async {
    // Si on n'a vraiment rien à afficher, on arrête
    if (title == null && body == null) return;

    await _localNotif.show(
      msg.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription: _canal.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(msg.data),
    );
  }
  // ── STOCKAGE LOCAL ────────────────────────────────────────────────────────
  Future<void> _sauvegarderNotification(RemoteMessage msg) async {
    if (msg.notification == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final liste  = _chargerDepuisPrefs(prefs);
      final modele = NotificationModel.fromRemoteMessage(msg);

      // Éviter les doublons (même messageId)
      final existeDeja = liste.any((n) => n.id == modele.id);
      if (existeDeja) return;

      liste.insert(0, modele); // plus récente en premier

      // Garder max 100 notifications
      if (liste.length > 100) liste.removeLast();

      await prefs.setString(
        _clePrefs,
        jsonEncode(liste.map((n) => n.toJson()).toList()),
      );

      // Notifier le ViewModel
      onNouvelleNotification?.call();
    } catch (e) {
      debugPrint('⚠️ Sauvegarde notif : $e');
    }
  }

  Future<List<NotificationModel>> chargerNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return _chargerDepuisPrefs(prefs);
  }

  List<NotificationModel> _chargerDepuisPrefs(SharedPreferences prefs) {
    final json = prefs.getString(_clePrefs);
    if (json == null) return [];
    try {
      final liste = jsonDecode(json) as List<dynamic>;
      return liste
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> marquerCommeLue(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = _chargerDepuisPrefs(prefs);
    for (final n in liste) {
      if (n.id == id) { n.estLue = true; break; }
    }
    await prefs.setString(
      _clePrefs,
      jsonEncode(liste.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> toutMarquerLues() async {
    final prefs = await SharedPreferences.getInstance();
    final liste = _chargerDepuisPrefs(prefs);
    for (final n in liste) { n.estLue = true; }
    await prefs.setString(
      _clePrefs,
      jsonEncode(liste.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> supprimerNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = _chargerDepuisPrefs(prefs)
      ..removeWhere((n) => n.id == id);
    await prefs.setString(
      _clePrefs,
      jsonEncode(liste.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> toutEffacer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clePrefs);
  }

  Future<int> getNombreNonLues() async {
    final liste = await chargerNotifications();
    return liste.where((n) => !n.estLue).length;
  }

  // ── HANDLERS PRIVÉS ───────────────────────────────────────────────────────
  Future<void> _onMessageForeground(RemoteMessage msg) async {
    // 1. Extraire les infos même si 'notification' est null (cas du Data Message)
    String? title = msg.notification?.title ?? msg.data['title'];
    String? body = msg.notification?.body ?? msg.data['body'];

    debugPrint('📩 Foreground reçu. Titre: $title, Data: ${msg.data}');

    // 2. Sauvegarder en local
    await _sauvegarderNotification(msg);

    // 3. Afficher la notification locale manuellement
    await _afficherNotificationManuelle(msg, title, body);
  }
  Future<void> _onMessageOuvert(RemoteMessage msg) async {
    debugPrint('👆 Tap background : ${msg.data}');
    await marquerCommeLue(
      msg.messageId ?? msg.data['id']?.toString() ?? '',
    );
    _traiterNavigation(msg.data);
  }

  @pragma('vm:entry-point')
  static void _onNotificationLocaleTappee(NotificationResponse resp) {
    if (resp.payload == null) return;
    try {
      final data = jsonDecode(resp.payload!) as Map<String, dynamic>;
      NotificationService.instance._traiterNavigation(data);
    } catch (e) {
      debugPrint('⚠️ Payload : $e');
    }
  }

  void _traiterNavigation(Map<String, dynamic> data) {
    // Toujours aller sur la page notifications
    // (on peut filtrer par type si nécessaire)
    NavigationService.versNotifications();
  }
}
*/

// ── Background handler (isolate séparé, pas d'accès au singleton) ─────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp();

  // Récupère le numéro sauvegardé lors du dernier login
  final prefs  = await SharedPreferences.getInstance();
  //final numero = prefs.getString('current_user_numero') ?? '';
  final numero= AppState().numeroUtilisateur;

  if (numero.isEmpty) return;

  // ✅ Lit title/body depuis data (Data Message)
  final d     = msg.data;
  final titre = d['title']?.toString() ?? '';
  final corps = d['body']?.toString()  ?? '';
  if (titre.isEmpty && corps.isEmpty)  return;

  await DatabaseHelper.instance.inserer(
    NotificationModel.fromRemoteMessage(msg, numero),
  );
  final nonLues = await DatabaseHelper.instance.compterNonLues(numero);
  await BadgeService.instance.mettreAJour(nonLues);

  debugPrint('📩 BG sauvegardé [${msg.data['type']}] : $titre');
}

// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging               _messaging  = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  String _numeroUser =AppState().numeroUtilisateur;
  VoidCallback? onNouvelleNotification;

  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    'eduniger_canal_principal',
    'Notifications EduNiger',
    description : "Notifications de l'application EduNiger",
    importance  : Importance.high,
  );

  // ── INIT (main.dart, avant runApp) ────────────────────────────────────────
  Future<void> initialiser() async {
    // 1. Canal Android ✅ correction du bug de résolution

    await _localNotif.resolvePlatformSpecificImplementation;
    AndroidFlutterLocalNotificationsPlugin()?.createNotificationChannel(_canal);

    // 2. flutter_local_notifications
    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS    : DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse          : _onLocaleTappee,
      onDidReceiveBackgroundNotificationResponse: _onLocaleTappee,
    );

    // 3. Handlers FCM
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOuverte);

    debugPrint('✅ NotificationService initialisé');
  }

  // ── DÉFINIR L'UTILISATEUR (appelé juste après login) ──────────────────────
  Future<void> definirUtilisateur(String numero) async {
    _numeroUser = numero;

    // Persiste pour le background handler (autre isolate)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_numero', numero);

    // App ouverte depuis notification quand elle était killed
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) {
      await _sauvegarder(initial);
      Future.delayed(const Duration(milliseconds: 600), () {
        _naviguer(initial.data);
      });
    }
  }

  // ── PERMISSION ────────────────────────────────────────────────────────────
  Future<bool> demanderAutorisation() async {
    final s = await _messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );
    return s.authorizationStatus == AuthorizationStatus.authorized ||
        s.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ── TOKEN ─────────────────────────────────────────────────────────────────
  Future<String> getToken() async {
    try { return await _messaging.getToken() ?? ''; }
    catch (e) { return ''; }
  }

  void ecouterRenouvellementToken(void Function(String) cb) =>
      _messaging.onTokenRefresh.listen(cb);

  // ── AFFICHER NOTIFICATION LOCALE ─────────────────────────────────────────
  // ✅ Lit title/body depuis data['title'] et data['body']
  Future<void> _afficher(RemoteMessage msg) async {
    final d     = msg.data;
    final titre = d['title']?.toString() ?? msg.notification?.title ?? '';
    final corps = d['body']?.toString()  ?? msg.notification?.body  ?? '';
    if (titre.isEmpty && corps.isEmpty) return;

    await _localNotif.show(
      msg.hashCode,
      titre,
      corps,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription: _canal.description,
          importance        : Importance.high,
          priority          : Priority.high,
          icon              : '@mipmap/ic_launcher',
          ticker            : titre,
          styleInformation  : BigTextStyleInformation(corps),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true,
        ),
      ),
      payload: jsonEncode(d), // toutes les données pour la navigation au tap
    );
  }

  // ── SAUVEGARDER EN SQLite ─────────────────────────────────────────────────
  Future<void> _sauvegarder(RemoteMessage msg) async {
    final d     = msg.data;
    final titre = d['title']?.toString() ?? msg.notification?.title ?? '';
    final corps = d['body']?.toString()  ?? msg.notification?.body  ?? '';

    if (titre.isEmpty && corps.isEmpty) {
      debugPrint('⚠️ Message ignoré : title et body vides');
      return;
    }

    // --- CORRECTION : Tentative de récupération si vide ---
    if (_numeroUser.isEmpty) {
      _numeroUser = AppState().numeroUtilisateur; // 1. Tenter via AppState

      if (_numeroUser.isEmpty) {
        // 2. Tenter via SharedPreferences (fallback ultime)
        final prefs = await SharedPreferences.getInstance();
        _numeroUser = prefs.getString('current_user_numero') ?? '';
      }
    }
    // -----------------------------------------------------

    if (_numeroUser.isEmpty) {
      debugPrint('⚠️ Utilisateur non défini après tentative de récupération, notif ignorée');
      return;
    }

    await DatabaseHelper.instance.inserer(
      NotificationModel.fromRemoteMessage(msg, _numeroUser),
    );


    // ✅ Mettre à jour le badge après sauvegarde
    final nonLues = await DatabaseHelper.instance.compterNonLues(_numeroUser);
    await BadgeService.instance.mettreAJour(nonLues);

    onNouvelleNotification?.call();
    debugPrint('✅ Sauvegardé [type:${d['type']}] "$titre" → user:$_numeroUser');
  }

  // ── ACCÈS BDD (délégation) ────────────────────────────────────────────────
  Future<List<NotificationModel>> chargerNotifications() =>
      _numeroUser.isEmpty
          ? Future.value([])
          : DatabaseHelper.instance.charger(_numeroUser);

  Future<int> getNombreNonLues() =>
      _numeroUser.isEmpty
          ? Future.value(0)
          : DatabaseHelper.instance.compterNonLues(_numeroUser);

 // Future<void> marquerCommeLue(String id) =>DatabaseHelper.instance.marquerLue(id, _numeroUser);
  Future<void> marquerCommeLue(String id) async {
    await DatabaseHelper.instance.marquerLue(id, _numeroUser);
    // ✅ Recalculer et mettre à jour le badge
    final nonLues = await DatabaseHelper.instance.compterNonLues(_numeroUser);
    await BadgeService.instance.mettreAJour(nonLues);
  }
  Future<void> toutMarquerLues() async {
    await DatabaseHelper.instance.toutMarquerLues(_numeroUser);
    //await BadgeService.instance.effacer(); // ✅ plus aucune non-lue → badge à 0
  }

  Future<void> supprimerNotification(String id) async {
    await DatabaseHelper.instance.supprimer(id, _numeroUser);
    // ✅ Recalculer après suppression
    final nonLues = await DatabaseHelper.instance.compterNonLues(_numeroUser);
    await BadgeService.instance.mettreAJour(nonLues);
  }

  Future<void> toutEffacer() async {
    await DatabaseHelper.instance.toutEffacer(_numeroUser);
    await BadgeService.instance.effacer(); // ✅ badge à 0
  }
  // ── HANDLERS PRIVÉS ───────────────────────────────────────────────────────
  Future<void> _onForeground(RemoteMessage msg) async {
    debugPrint('📩 Foreground | title:${msg.data['title']} type:${msg.data['type']}');
    await _sauvegarder(msg);
    await _afficher(msg); // ← obligatoire en foreground, FCM n'affiche pas
  }

  Future<void> _onOuverte(RemoteMessage msg) async {
    debugPrint('👆 Tap background : ${msg.data}');
    final id = msg.messageId ?? msg.data['id']?.toString() ?? '';
    if (id.isNotEmpty) await marquerCommeLue(id);
    _naviguer(msg.data);
  }

  @pragma('vm:entry-point')
  static void _onLocaleTappee(NotificationResponse resp) {
    if (resp.payload == null) return;
    try {
      final data = jsonDecode(resp.payload!) as Map<String, dynamic>;
      NotificationService.instance._naviguer(data);
    } catch (e) {
      debugPrint('⚠️ Payload invalide : $e');
    }
  }

  // ── NAVIGATION selon data['type'] du serveur ──────────────────────────────
  void _naviguer(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    debugPrint('📌 Navigation type=$type');
    switch (type) {
      /*
      case '1' : NavigationService.versRoute('/cours',    arguments: data); break;
      case '2' : NavigationService.versRoute('/messages', arguments: data); break;
    */
      default  : NavigationService.versNotifications();
    }
  }
}
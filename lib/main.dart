import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:eduniger/utils/Routeur.dart';
import 'package:eduniger/utils/themeperso.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'appstate.dart';
import 'features/notification/service/notification_service.dart';
import 'features/utilisateurs/repositories/user_repositorie.dart';
import 'features/utilisateurs/repositories/postmant_user_repositore.dart';
import 'features/utilisateurs/view_models/user_view_model.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:eduniger/utils/Routeur.dart';
import 'package:eduniger/utils/themeperso.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'appstate.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:eduniger/utils/Routeur.dart';
import 'package:eduniger/utils/themeperso.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'appstate.dart';
import 'features/notification/service/notification_service.dart';

// 1. Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Assurez-vous d'initialiser Firebase ici aussi pour le background
  await Firebase.initializeApp();
  print("Message en arrière-plan reçu: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation Firebase
  await Firebase.initializeApp();

  // 3. Enregistrement du handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // 4. Initialisation du service de notifications local
  await NotificationService.instance.initialiser();

  AppState appState = AppState();
  await appState.chargerSessionLocale();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: EduNigerApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class EduNigerApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const EduNigerApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const DispatcherPage(),
          routes: Routeur.route,
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [
            Locale('fr', 'FR'),
            Locale('en', 'US'),
            Locale('ar', 'EG'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemePerso.ModeClaire,
          darkTheme: ThemePerso.ModeSombre,
          themeMode: appState.themeChoisie ?? ThemeMode.system,
        );
      },
    );
  }
}

class DispatcherPage extends StatelessWidget {
  const DispatcherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    if (appState.estConnecter) {
      return Routeur.route['/mainPage']!(context);
    } else {
      return Routeur.route['/logine']!(context);
    }
  }
}
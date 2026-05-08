import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:eduniger/features/categorie/repositorie/postmant_categorie_repositorie.dart';
import 'package:eduniger/utils/Routeur.dart';
import 'package:eduniger/utils/themeperso.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'appstate.dart';
import 'features/accueil/repositorie/pastmant_acceuil_repositorie.dart';
import 'features/accueil/view_model/accueil_view_model.dart';
import 'features/categorie/view_model/categorie_view_model.dart';
import 'features/lecteur_audio/view_model/lecteur_audio_view_model.dart';
import 'features/lecteur_pdf/view_model/lecteur_pdf_view_model.dart';
import 'features/livres/repositories/postmant_book_repositorie.dart';
import 'features/livres/view_models/book_view_model.dart';
import 'features/notification/service/notification_service.dart';
import 'features/notification/view_model/notification_view_model.dart';
import 'features/structures/repositories/postmant_structure_repositorie.dart';
import 'features/structures/view_model/structure_view_model.dart';
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
    /*ChangeNotifierProvider.value(
      value: appState,
      child: EduNigerApp(savedThemeMode: savedThemeMode),
    ),*/
    MultiProvider(

      providers: [
        // ── 1. AppState : état global (session, thème, urls) ──────────
        ChangeNotifierProvider<AppState>.value(
          value: appState,
        ),

        // ── 2. UserViewModel : connexion / inscription / mot de passe ─
        ChangeNotifierProvider<UserViewModel>(
          create: (_) => UserViewModel(
            PostmantUserRepositoie(),
            appState,
          ),
        ),

        // ── 3. NotificationViewModel ───────────────────────────────────
        ChangeNotifierProvider<NotificationViewModel>(
          create: (_) => NotificationViewModel(appState),
        ),

        ChangeNotifierProxyProvider<AppState, AccueilViewModel>(
          // create : valeur initiale (avant le premier update)
          create: (_) => AccueilViewModel(
            PostmantAccueilRepository(),
            appState,
          ),
          // update : recréé quand AppState change (ex: après login)
          update: (_, appState, previous) {
            // Si le numéro a changé (après login), on recrée le VM
            if (previous?.numero != appState.numeroUtilisateur &&
                appState.estConnecter) {
              return AccueilViewModel(
                PostmantAccueilRepository(),
                appState,
              );
            }
            return previous ??
                AccueilViewModel(PostmantAccueilRepository(), appState);
          },
        ),
          //les categorie
        ChangeNotifierProxyProvider<AppState, CategorieViewModel>(
          // create : valeur initiale (avant le premier update)
          create: (_) => CategorieViewModel(
            PostmantCategorieRepositorie(),
            appState,
          ),
          // update : recréé quand AppState change (ex: après login)
          update: (_, appState, previous) {
            // Si le numéro a changé (après login), on recrée le VM
            if (previous?.numero != appState.numeroUtilisateur &&
                appState.estConnecter) {
              return CategorieViewModel(
                PostmantCategorieRepositorie(),
                appState,
              );
            }
            return previous ??
                CategorieViewModel(PostmantCategorieRepositorie(), appState);
          },
        ),
          //les sructures
        ChangeNotifierProxyProvider<AppState, StructureViewModel>(
          // create : valeur initiale (avant le premier update)
          create: (_) => StructureViewModel(
            PostmantStructureRepositorie(),
            appState,
          ),
          // update : recréé quand AppState change (ex: après login)
          update: (_, appState, previous) {
            // Si le numéro a changé (après login), on recrée le VM
            if (previous?.numero != appState.numeroUtilisateur &&
                appState.estConnecter) {
              return StructureViewModel(
                PostmantStructureRepositorie(),
                appState,
              );
            }
            return previous ??
                StructureViewModel(PostmantStructureRepositorie(), appState);
          },
        ),

        // ── 5. BookViewModel : même logique ───────────────────────────
        ChangeNotifierProxyProvider<AppState, BookViewModel>(
          create: (_) => BookViewModel(
            PostmantBookRepositorie(),
            appState,
          ),
          update: (_, appState, previous) {
            if (previous?.numero != appState.numeroUtilisateur &&
                appState.estConnecter) {
              return BookViewModel(
                PostmantBookRepositorie(),
                appState,
              );
            }
            return previous ??
                BookViewModel(PostmantBookRepositorie(), appState);
          },
        ),
        // Dans MultiProvider — ajouter :
        ChangeNotifierProvider<LecteurAudioViewModel>(
          create: (_) => LecteurAudioViewModel(),
        ),
        ChangeNotifierProvider<LecteurPdfViewModel>(
          create: (_) => LecteurPdfViewModel(),
        ),

      ],
      child: EduNigerApp(savedThemeMode: savedThemeMode),
    )
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
    // ← isInitialized : attend que la session locale soit chargée
    return Consumer<AppState>(
      builder: (context, appState, _) {
        // Chargement en cours
        if (!appState.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }

        // Redirige selon l'état de connexion
        if (appState.estConnecter) {
          return Routeur.route['/mainPage']!(context);
        } else {
          return Routeur.route['/logine']!(context);
        }
      },
    );
  }
}
/*
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
*/
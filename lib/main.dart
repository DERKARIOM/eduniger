import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:eduniger/utils/Routeur.dart';
import 'package:eduniger/utils/themeperso.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'appstate.dart';
import 'features/utilisateurs/repositories/user_repositorie.dart';
import 'features/utilisateurs/repositories/postmant_user_repositore.dart';
import 'features/utilisateurs/view_models/user_view_model.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  // On récupère l'instance unique du Singleton
  AppState appState = AppState();

  runApp(
     ChangeNotifierProvider(
         create: (context) => appState,
         child: EduNigerApp(savedThemeMode: savedThemeMode)
     ),
    
  );
}

class EduNigerApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const EduNigerApp({super.key,this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    // On écoute AppState pour mettre à jour le thème dynamiquement
    context.watch<AppState>();
    return AdaptiveTheme(
        light: ThemeData.light(useMaterial3: true
        ),
        dark: ThemeData.dark(useMaterial3: true

        ),
        initial: AdaptiveThemeMode.light,
        //initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) =>
        MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routeur.routeInitiale,
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
        theme: theme,
        darkTheme: darkTheme,
        // On utilise l'instance du provider 'state'

        // themeMode: AppState().themeChoisie ?? ThemeMode.system,
            ),
    );

  }
}
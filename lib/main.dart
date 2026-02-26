
import 'package:eduniger/pages/bootomBart/accueil_page.dart';
import 'package:eduniger/pages/bootomBart/main_page.dart';
import 'package:eduniger/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'localDataBase/sqlflitEduniger.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent
      statusBarIconBrightness: Brightness.dark, // Icônes foncées (pour fond clair)
      statusBarBrightness: Brightness.light,
    ),
  );
  // Vérifier la session
 // bool sessionActive = await DatabaseHelper.instance.isSessionValid();
  bool sessionActive = false;
  try {
    sessionActive = await DatabaseHelper.instance.isSessionValid();
  } catch (e) {
    print("Erreur initialisation session: $e");
    sessionActive = false;
  }
  runApp(EduNigerApp(initialRoute: sessionActive ? '/home' : '/login'));

  //runApp(EduNigerApp());
}

class EduNigerApp extends StatelessWidget {
  final String initialRoute;
  const EduNigerApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute, // L'app démarre sur la bonne page
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) =>MainPage(
        ),
      },
      //home: LoginPage(),
    );
  }
}
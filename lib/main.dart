import 'package:eduniger/pages/home_page.dart';
import 'package:eduniger/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent
      statusBarIconBrightness: Brightness.dark, // Icônes foncées (pour fond clair)
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(EduNigerApp());
}

class EduNigerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
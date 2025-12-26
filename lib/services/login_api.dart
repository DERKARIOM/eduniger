import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/modelUser.dart';



// Résultat de la tentative de connexion
class LoginResult {
  final bool success;
  final String message;
  final User? user;

  LoginResult({
    required this.success,
    required this.message,
    this.user,
  });
}

// Service d'authentification
class AuthService {
  static const String baseUrl = 'http://192.168.49.1:2222/fabi/android';

  /// Connexion utilisateur
  ///
  /// [idNumber] : ID de l'utilisateur
  /// [password] : Mot de passe
  /// [version] : Version de l'application
  ///
  /// Retourne un [LoginResult] avec le statut de la connexion
  static Future<LoginResult> login({
    required String idNumber,
    required String password,
    required String version,
  }) async {
    final url = '$baseUrl/login.php';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idNumber': idNumber,
          'password': password,
          'version': version,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (kDebugMode) {
          print(responseBody);
        }
        // Vérifier les cas d'erreur
        if (responseBody == 'incorrectPassword') {
          return LoginResult(
            success: false,
            message: 'Mot de passe incorrect',
          );
        } else if (responseBody == 'accountNotExist') {
          return LoginResult(
            success: false,
            message: 'Ce compte n\'existe pas',
          );
        } else if (responseBody == 'expiresVersion') {
          return LoginResult(
            success: false,
            message: 'Version de l\'application obsolète. Veuillez mettre à jour.',
          );
        } else {
          // Tentative de parser l'utilisateur
          try {
            final userData = jsonDecode(responseBody);
            final user = User.fromJson(userData);

            return LoginResult(
              success: true,
              message: 'Connexion réussie',
              user: user,
            );
          } catch (e) {
            return LoginResult(
              success: false,
              message: 'Erreur lors du traitement des données: ${e.toString()}',
            );
          }
        }
      } else {
        return LoginResult(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Erreur de connexion: ${e.toString()}',
      );
    }
  }
}

// Exemple d'utilisation dans un widget
/*
Future<void> handleLogin() async {
  final result = await AuthService.login(
    idNumber: idController.text,
    password: passwordController.text,
    version: '1.0.0', // Version de votre app
  );

  if (result.success && result.user != null) {
    // Connexion réussie
    print('Bienvenue ${result.user!.firstName} ${result.user!.name}');

    // Sauvegarder l'utilisateur localement (SharedPreferences, etc.)
    // Naviguer vers l'écran principal
  } else {
    // Afficher le message d'erreur
    print('Erreur: ${result.message}');
    // Afficher un SnackBar ou Dialog avec result.message
  }
}
*/
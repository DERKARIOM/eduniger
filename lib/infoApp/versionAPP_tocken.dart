import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppInfo {
  // Récupérer la version de l'application
  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // Retourne "3.1.3"
  }

  // Récupérer le token Firebase
  static Future<String> getFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      return token ?? 'token_firbase_default';
    } catch (e) {
      return 'token_firbase_error';
    }
  }
}
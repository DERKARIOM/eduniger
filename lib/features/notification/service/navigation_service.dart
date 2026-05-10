import 'package:flutter/material.dart';

/// Permet de naviguer depuis n'importe où (y compris depuis le NotificationService)
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static NavigatorState get _nav => navigatorKey.currentState!;

  static Future<void> versNotifications() async {
    // Pousse /notification sans supprimer la pile
    _nav.pushNamed('/notification');
  }

  static Future<void> versRoute(String route, {Object? arguments}) async {
    _nav.pushNamed(route, arguments: arguments);
  }
}
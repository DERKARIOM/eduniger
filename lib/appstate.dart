import 'package:flutter/material.dart';

import 'features/utilisateurs/repositories/postmant_user_repositore.dart';
import 'features/utilisateurs/view_models/user_view_model.dart';
class AppState extends ChangeNotifier {
  static final AppState _singleton = AppState._internal();
  AppState._internal() {
    // ← ViewModels initialisés une seule fois dans le singleton
    final repo = PostmantUserRepositoie();
    _utilisa   = UserViewModel(repo, this);

  }

  factory AppState() => _singleton;

  // ── État global ──────────────────────────────────────────────────────
  bool       estConnecter = false;
  ThemeMode? themeChoisie;

  // ── ViewModels accessibles depuis toute l'app ────────────────────────
  late UserViewModel               _utilisa;

  UserViewModel               get utilisa    => _utilisa;

  // ── Notifier l'UI depuis n'importe quel ViewModel ────────────────────
  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}
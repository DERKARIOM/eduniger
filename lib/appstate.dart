import 'package:flutter/material.dart';

import 'features/livres/repositories/postmant_book_repositorie.dart';
import 'features/livres/view_models/book_view_model.dart';
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
  //late BookViewModel _bookVM;

  // ── ViewModels accessibles depuis toute l'app ────────────────────────
  late UserViewModel               _utilisa;

  UserViewModel               get utilisa    => _utilisa;
 // BookViewModel get bookVM => _bookVM;
  // ── Notifier l'UI depuis n'importe quel ViewModel ────────────────────
  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // Dans AppState, ajouter :


// Dans AppState._internal(), après connexion utilisateur :
  /*
  void initialiserBookVM(String numero, String version) {
    _bookVM = BookViewModel(
      repositorie : PostmantBookRepositorie(),
      numero      : numero,
      version     : version,
    );

    update(() {});  // notifie l'UI
  }
*/
// Dans UserViewModel, après login réussi :
  //appState.initialiserBookVM(user.numero, _appVersion);
}
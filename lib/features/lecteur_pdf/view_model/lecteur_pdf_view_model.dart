import 'package:flutter/cupertino.dart';

class LecteurPdfViewModel extends ChangeNotifier {
  String  _chemin        = '';
  String  _titre         = '';
  int     _pageCourante  = 1;
  int     _totalPages    = 0;
  bool    _isLoading     = true;
  bool    _afficherBarre = true;
  String  _errorMessage  = '';
  double  _zoom          = 1.0;

  String  get chemin        => _chemin;
  String  get titre         => _titre;
  int     get pageCourante  => _pageCourante;
  int     get totalPages    => _totalPages;
  bool    get isLoading     => _isLoading;
  bool    get afficherBarre => _afficherBarre;
  String  get errorMessage  => _errorMessage;
  double  get zoom          => _zoom;

  // Progression 0.0 → 1.0
  double get progression =>
      _totalPages > 0
          ? (_pageCourante / _totalPages).clamp(0.0, 1.0)
          : 0.0;

  void initialiser(String chemin, String titre) {
    _chemin = chemin;
    _titre  = titre;
    notifyListeners();
  }

  void onDocumentLoaded(int pages) {
    _totalPages = pages;
    _isLoading  = false;
    notifyListeners();
  }

  void onPageChanged(int page, int total) {
    _pageCourante = page;
    _totalPages   = total;
    notifyListeners();
  }

  void onError(String error) {
    _errorMessage = error;
    _isLoading    = false;
    notifyListeners();
  }

  void toggleBarre() {
    _afficherBarre = !_afficherBarre;
    notifyListeners();
  }
}
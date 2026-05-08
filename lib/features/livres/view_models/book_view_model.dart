import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eduniger/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../localDataBase/sqlflitEduniger.dart';
import '../dto/detaille_book_dto.dart';
import '../models/book_model.dart';
import '../models/detaille_book_model.dart';
import '../models/livres_model.dart';
import '../repositories/book_repository.dart';

class BookViewModel extends ChangeNotifier {
  final BookRepository repositorie;
  final AppState appState;
  late String numero;      // ← ID de l'utilisateur connecté
  late String version;     // ← version de l'app
  BookViewModel(
     this.repositorie,
     this.appState,

  ) {
    numero=appState.numeroUtilisateur;
    version=appState.version;
    _init();
  }

  // ══════════════════════════════════════════════════════════════════════
  // ÉTAT
  // ══════════════════════════════════════════════════════════════════════
  List<LivresModel> _livres            = [];
  List<Book> _livresRecomandes  = [];
  List<Book> _livresElectro     = [];
  List<Book> _livresAudio       = [];
  List<DetailleBookModel> _livresTelecharges = [];
  List<Book> _livresEmpruntes   = [];
  List<DetailleBookModel> _livresLocaux      = [];   // ← stockés en local SQLite

  BookDetailDto? _detailLivre;
  String  _errorMessage        = '';
  String _token  ='';
  bool    _isLoading           = false;
  bool    _isLoadingDetail     = false;
  bool    _isDownloading       = false;
  bool    _isTelecharge_pdf=false;
  bool    _isTelecharge_audio=false;

  bool     _isReserve=false;
  bool   _liker=false;
  bool   _noliker=false;
  bool   _subscribe=false;

  double  _downloadProgress    = 0.0;  // 0.0 → 1.0
  String  _actionMessage       = '';   // retour des actions like/vue/etc.
   String base =
      'https://eduniger.com/admin-api/storage/app/private/structures/';

  // ── Getters ────────────────────────────────────────────────────────
  bool get isReserve => _isReserve;
  bool get liker => _liker;
  bool get noliker => _noliker;
  bool get subscribe => _subscribe;
  bool get isTelecharge_pdf => _isTelecharge_pdf;
  bool get isTelecharge_audio => _isTelecharge_audio;
  String get token => _token;
  BookDetailDto? get livreDetail       => _detailLivre;
  List<LivresModel>    get livres            => _livres;
  List<Book>    get livresRecomandes  => _livresRecomandes;
  List<Book>    get livresElectro     => _livresElectro;
  List<Book>    get livresAudio       => _livresAudio;
  List<DetailleBookModel>    get livresTelecharges => _livresTelecharges;
  List<Book>    get livresEmpruntes   => _livresEmpruntes;
  List<DetailleBookModel>    get livresLocaux      => _livresLocaux;
  BookDetailDto? get detailLivre       => _detailLivre;
  String             get errorMessage      => _errorMessage;
  bool               get isLoading         => _isLoading;
  bool               get isLoadingDetail   => _isLoadingDetail;
  bool               get isDownloading     => _isDownloading;
  double             get downloadProgress  => _downloadProgress;
  String             get actionMessage     => _actionMessage;

  // ══════════════════════════════════════════════════════════════════════
  // INITIALISATION
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _init() async {
    //await recupere_tocken();
    // Chargement parallèle pour gagner du temps
    await Future.wait([
      chargerLivres(),
      //chargerRecomandes(),
      chargerLivresLocaux(),   // ← livres hors-ligne dès le démarrage
    ]);
  }
  // ══════════════════════════════════════════════════════════════════════
// ÉTAT SUPPLÉMENTAIRE
// ══════════════════════════════════════════════════════════════════════
// Suivi par livre : id_book → progress
  final Map<String, double> _progressParLivre  = {};
  final Map<String, bool>   _enCoursParLivre   = {};
  final Map<String, bool>   _reserveParLivre   = {};

  Map<String, double> get progressParLivre => _progressParLivre;
  Map<String, bool>   get enCoursParLivre  => _enCoursParLivre;
  Map<String, bool>   get reserveParLivre  => _reserveParLivre;
  // ── État enrichi ───────────────────────────────────────────────────────
 final Map<String, String>   _statutReservation  = {}; // 'en_attente'|'confirmee'
  final Map<String, DateTime> _dateReservation    = {};
  final Map<String, bool>     _dejaTelechage_pdf      = {};  // cache local
  final Map<String, bool>     _dejaTelechage_audio      = {};  // cache local

  Map<String, String>   get statutReservation => _statutReservation;
  Map<String, DateTime> get dateReservation   => _dateReservation;
   Map<String, bool> get dejaTelechage_pdf => _dejaTelechage_pdf;
   Map<String, bool> get dejaTelechage_audio => _dejaTelechage_audio;

  //__________________________________________________________
  // ── Correction 1 : _getExtension gère la chaîne vide ─────────────────
  String _getExtension_pdf(BookDetailDto detail) {
    // electronic est un String? qui peut être null OU vide ""
    if (detail.electronic != null &&
        detail.electronic!.isNotEmpty &&
        detail.electronic != 'false' &&
        detail.electronic != '0') {
      return 'pdf';
    }
    return '';
  }
  //recuperer extension audio
  String _getExtension_audio(BookDetailDto detail) {
    if (detail.isAudio == true) return 'mp3';
    return '';
  }

// ── Correction 2 : _getUrlFichier avec vérifications complètes ────────
  String _getUrlFichier_pdf(BookDetailDto detail) {
    if (detail.idStructure == null || detail.idStructure!.isEmpty) {
      debugPrint("⚠️ idStructure nul ou vide");
      return '';
    }


    // PDF : electronic contient le nom du fichier
    if (detail.electronic != null &&
        detail.electronic!.isNotEmpty &&
        detail.electronic != 'false' &&
        detail.electronic != '0') {

      final url = 'http://78.46.46.154/eduniger/admin-api/storage/app/private/structures/${detail.idStructure}/pdfs/${detail.electronic}';
      //final url = '$base${detail.idStructure}/pdfs/${detail.electronic}';
      debugPrint("📄 URL PDF : $url");
      return url;
    }
    debugPrint("⚠️ Aucun format détectable");
    return '';
  }
//url de audio
  String _getUrlFichier_audio(BookDetailDto detail) {
    if (detail.idStructure == null || detail.idStructure!.isEmpty) {
      debugPrint("⚠️ idStructure nul ou vide");
      return '';
    }



    // Audio
    if (detail.isAudio == true && detail.idBook != null) {
     final url ='http://bienvenueafricains.com/mp3/hausa/The%20Way%20of%20Righteousness/_Adam_to_Abraham/001.mp3';
      //final url = 'http://78.46.46.154/eduniger/admin-api/storage/app/private/structures/${detail.idStructure}/audios/${detail.idBook}.mp3';
      //final url = '$base${detail.idStructure}/audios/${detail.idBook}.mp3';
      debugPrint("🎵 URL Audio : $url");
      return url;
    }

    debugPrint("⚠️ Aucun format détectable");
    return '';
  }

// ── Correction 3 : telechargerLivre — string interpolation corrigée ───
  Future<void> telechargerLivre(BookDetailDto detail,bool type_pdf ,bool type_audio) async {
    final String idBook = detail.idBook ?? '';
    String typeSuffix = type_pdf ? "_pdf" : "_audio";
    if (idBook.isEmpty) {
      debugPrint("❌ idBook vide");
      return;
    }
    String uniqueKey = "${detail.idBook}$typeSuffix";

    if (type_pdf && _dejaTelechage_pdf[uniqueKey] == true) {
      _actionMessage = 'ouvrir_$idBook';   // ← corrigé
      notifyListeners();
      return;
    }
    if ( type_audio &&_dejaTelechage_audio[uniqueKey] == true) {
      _actionMessage = 'ouvrir_$idBook';   // ← corrigé
      notifyListeners();
      return;
    }
    // Déjà en cours → ignorer
    if (_enCoursParLivre[uniqueKey] == true) return;
      notifyListeners();
    // Démarrer
    _enCoursParLivre[uniqueKey]  = true;
    _progressParLivre[uniqueKey] = 0.0;
    _errorMessage = '';
    notifyListeners();

    // Lancer en arrière-plan
    await(_lancerTelechargementBackground(detail, idBook,type_pdf,type_audio,uniqueKey));
  }

// ── Correction 4 : _lancerTelechargementBackground robuste ───────────
  Future<void> _lancerTelechargementBackground(
      BookDetailDto detail, String idBook,bool type_pdff,bool type_audioo,String uniqueKey)
  async
  {
    try {
      // 1. Vérifications préalables
      final String extension =type_pdff ? _getExtension_pdf(detail) :type_audioo? _getExtension_audio(detail):'';
      if (extension.isEmpty) {
        _finirTelechargement(idBook, succes: false,
            erreur: 'Format de livre non reconnu');
        return;
      }

      final String url = type_pdff ?_getUrlFichier_pdf(detail):type_audioo? _getUrlFichier_audio(detail):'';
      if (url.isEmpty) {
        _finirTelechargement(idBook, succes: false,
            erreur: 'URL de téléchargement introuvable');
        return;
      }

      // 2. Dossier de destination
      final dir = await getApplicationDocumentsDirectory();
      final String dossier = '${dir.path}/livres';
      final String couverture = '${dir.path}/couvertures';
      await Directory(dossier).create(recursive: true);
      await Directory(couverture).create(recursive: true);
      final String chementCouverture='$couverture/${detail.bookBlanket}';
      final String cheminLocal =
          '$dossier/${idBook}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // 3. Récupérer le token API (stocké dans la DB)
     /* if (_token.isEmpty) await recupere_tocken();
      debugPrint("🔑 Token API : ${_token.isNotEmpty ? '${_token.substring(0, 20)}...' : 'VIDE'}");
      */
      // 4. Configuration Dio
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 10);
      dio.options.followRedirects = true;
      dio.options.maxRedirects    = 5;
      //dio.options.headers['Content-Type'] = 'application/json';
      //dio.options.headers['Authorization'] = 'Bearer $_token';

      // Headers d'authentification
     /* if (_token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $_token';
      }
*/
      // 5. Téléchargement avec gestion fine des erreurs
      double derniereProgress = 0.0;
      List<Response> responses = await Future.wait(
          [dio.download(
      url,
      cheminLocal,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          final double nouvelleProgress = received / total;
          // Notifier seulement si progression > 1%
          if (nouvelleProgress - derniereProgress >= 0.01 ||
              nouvelleProgress >= 1.0) {
            derniereProgress = nouvelleProgress;
            _progressParLivre[uniqueKey] = nouvelleProgress;
            notifyListeners();
          }
        }
      },
    options: Options(
    // Ne pas lancer d'exception sur les codes d'erreur HTTP
    validateStatus: (status) => status != null && status < 500,
     receiveDataWhenStatusError: true,
      ),
     ),

        dio.download( '${AppState.baseUrlCover}${detail.idStructure}/blankets/${detail.bookBlanket}',
            chementCouverture)

          ]
      );
      //final Response response = await

      debugPrint("📥 Statut réponse : ${responses[0].statusCode} ${responses[1].statusCode}");

      // 6. Vérifier le code de retour
      if (responses[0].statusCode == 401) {
        _finirTelechargement(idBook, succes: false, erreur: 'Non autorisé. Veuillez vous reconnecter.');
       // _nettoyer(cheminLocal);
       // _nettoyer(chementCouverture);
        return;
      }

      if (responses[0].statusCode == 403) {
        _finirTelechargement(idBook, succes: false,
            erreur: 'Accès refusé à ce fichier.');
        _nettoyer(cheminLocal);
        _nettoyer(chementCouverture);
        return;
      }

      if (responses[0].statusCode == 404) {
        _finirTelechargement(idBook, succes: false,
            erreur: 'Fichier introuvable sur le serveur.');
        _nettoyer(cheminLocal);
        _nettoyer(chementCouverture);
        return;
      }

      if (responses[0].statusCode != 200) {
        _finirTelechargement(idBook, succes: false,
            erreur: 'Erreur serveur (${responses[0].statusCode})');
        _nettoyer(cheminLocal);
        _nettoyer(chementCouverture);
        return;
      }
      // ... (après le téléchargement)

      // 7. Vérifier l'intégrité du fichier
      final file = File(cheminLocal);
      final int taille = await file.length();

      // Un PDF fait rarement moins de 10 Ko. 1.3 Ko est presque certainement une erreur HTML
      if (taille < 200) {
        _nettoyer(cheminLocal);
        _nettoyer(chementCouverture);
        debugPrint("❌ Le fichier reçu taille   $taille octets.");
        _finirTelechargement(idBook, succes: false,
            erreur: 'Le fichier reçu est invalide (trop petit).');
        return;
      }

      // 8. Vérifier que c'est bien un PDF (Le "Magic Number")
      if (extension == 'pdf') {
        final bool valide = await _verifierFichierPdf(file);
        if (!valide) {
          _nettoyer(cheminLocal);
          _nettoyer(chementCouverture);
          _finirTelechargement(idBook, succes: false,
              erreur: 'Le serveur a renvoyé une erreur au lieu du PDF.');
          return;
        }
      }



      // 8. Sauvegarder en SQLite
      if (cheminLocal.isEmpty) {
        throw Exception("Le chemin local du fichier est vide");
      }

      final DetailleBookModel bookLocal = DetailleBookModel(
        id              : idBook,
        titre           : detail.bookTitle      ?? 'Sans titre',
        couverture      : chementCouverture,
        description     : detail.description     ?? '',
        titre_categorie : detail.categoryTitle   ?? '',
        est_pysique     : detail.isPhysic        ?? false,
        est_electronique: extension == 'pdf' ? '1' : '0',
        est_audio       : detail.isAudio         ?? false,
        nombre_jaime    : detail.numberLike      ?? 0,
        nombre_no_jaime : detail.numberNoLike    ?? 0,
        nombre_subscribe: detail.numberSubscribe ?? 0,
        nombre_vue      : detail.numberView      ?? 0,
        fichier         : cheminLocal,
      );

      //final String numSecurise = numero.isNotEmpty ? numero : '0000';
      final String numSecurise = (numero != null && numero.isNotEmpty) ? numero : '0000';
      await DatabaseHelper.instance.saveBookTelecharge(
          bookLocal, cheminLocal, numSecurise,chementCouverture,type_pdff,type_audioo);
      debugPrint("💾 Sauvegarde en base de données pour l'utilisateur : $numSecurise $type_pdff $type_audioo");

      await chargerLivresLocaux();

      type_pdff ?_dejaTelechage_pdf[uniqueKey] = true:type_audioo ?_dejaTelechage_audio[uniqueKey] = true:false;
      notifyListeners();
      _progressParLivre[uniqueKey] = 1.0;
      _finirTelechargement(idBook, succes: true);
      _enCoursParLivre[uniqueKey] = false;
     // _nettoyer(cheminLocal);
      //_nettoyer(chementCouverture);
      notifyListeners();
      debugPrint("✅ Téléchargé : $cheminLocal ($taille octets)");

    } on DioException catch (e) {
      debugPrint("❌ DioException : ${e.type} | ${e.message}");
      String messageErreur;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          messageErreur = 'Délai dépassé. Vérifiez votre connexion.';
          break;
        case DioExceptionType.connectionError:
          messageErreur = 'Pas de connexion internet.';
          break;
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode;
          if (code == 401 || code == 403) {
            messageErreur = 'Non autorisé. Reconnectez-vous.';
          } else {
            messageErreur = 'Erreur serveur ($code).';
          }
          break;
        default:
          messageErreur = 'Erreur réseau : ${e.message ?? 'inconnue'}';
      }
      _finirTelechargement(idBook, succes: false, erreur: messageErreur);

    } catch (e, stack) {
      debugPrint("❌ Erreur inattendue : $e");
      debugPrint("Stack : $stack");
      _finirTelechargement(idBook, succes: false,
          erreur: 'Erreur inattendue. Réessayez.');
    }
  }


  Future<bool> _verifierFichierPdf(File file) async {
    try {
      final bytes = await file.openRead(0, 5).first;
      final header = String.fromCharCodes(bytes);
      return header.startsWith('%PDF');
    } catch (_) {
      return false;
    }
  }

// ── Supprimer fichier si téléchargement échoué ────────────────────────
  Future<void> _nettoyer(String chemin) async {
    try {
      final f = File(chemin);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
  //____________________________________________________________

  //recuperer le tocken
  /*
  Future<void> recupere_tocken() async {
    try {
      // Utiliser .instance pour accéder à la base de données déjà ouverte
      final tokenData = await DatabaseHelper.instance.gettoken();
      _token = tokenData ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la récupération du token : $e");
      _token = '';
    }
  }
*/
// ── Vérifier état téléchargement au chargement du détail ──────────────
  Future<void> verifierEtatFichier(String idBook) async {
    bool deja_pdf= await DatabaseHelper.instance.isBookTelecharge_pdf(idBook, numero);
    _dejaTelechage_pdf[idBook] = deja_pdf;
    bool deja_audio = await DatabaseHelper.instance.isBookTelecharge_audio(idBook, numero);
    _dejaTelechage_audio[idBook] = deja_audio;
    // Vérifier aussi la réservation
    final bool reserve = await DatabaseHelper.instance
        .isReserve(idBook, numero);
    if (reserve) {
      final reservations = await DatabaseHelper.instance
          .getReservations(numero);
      final res = reservations
          .where((r) => r['id_book'] == idBook)
          .firstOrNull;
      if (res != null) {
        _statutReservation[idBook] = res['statut']?.toString() ?? '';
        _dateReservation[idBook]   = DateTime.parse(
            res['date_reservation']?.toString() ??
                DateTime.now().toIso8601String());
      }
    }
    notifyListeners();
  }

// ══════════════════════════════════════════════════════════════════════
// TÉLÉCHARGEMENT — arrière-plan + bouton progressif
// ══════════════════════════════════════════════════════════════════════
  /*
  Future<void> telechargerLivre(BookDetailDto detail) async {

    final String idBook = detail.idBook ?? '';
    if (idBook.isEmpty)
      {
        debugPrint("❌ Erreur : L'ID du livre est nul ou vide dans le modèle");
        return;
      }

    // 1. Déjà téléchargé → ouvrir directement
    if (_dejaTelechage[detail.idBook] == true) {
      _actionMessage = 'ouvrir_$detail.idBook';
      notifyListeners();
      return;
    }

    // 2. Déjà en cours → ignorer
    if (_enCoursParLivre[detail.idBook] == true) return;
    // 3. Démarrer
    _enCoursParLivre[idBook]  = true;
    _progressParLivre[idBook] = 0.0;
    _errorMessage = '';
    notifyListeners();

    // 4. Lancer EN ARRIÈRE-PLAN (ne bloque pas l'UI)
    _lancerTelechargementBackground(detail,idBook);
  }

// ── Arrière-plan : isolé dans une méthode séparée ─────────────────────
 /*
  Future<void> _lancerTelechargementBackground(
      BookDetailDto detail,String idBook) async
  {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String dossierLivres = '${dir.path}/livres';
      await Directory(dossierLivres).create(recursive: true);

      final String extension = _getExtension(detail);
      final String url = _getUrlFichier(detail);

      if (extension.isEmpty || url.isEmpty) {
        _finirTelechargement(idBook, succes: false, erreur: 'Lien ou format invalide');
        return;
      }

      final String cheminLocal = '$dossierLivres/${idBook}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      if (_token.isEmpty) {
        await recupere_tocken();
      }

      debugPrint("URL : $url");
      debugPrint("Token utilisé : ${_token}");
      debugPrint("Chemin local : $cheminLocal");

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $_token';
      final response = await dio.download(url, cheminLocal);

      if (response.statusCode != 200) {
        //client.close();
        _finirTelechargement(idBook, succes: false, erreur: 'Erreur serveur (${response.statusCode})');
        return;
      }

      final int totalBytes = response.contentLength ?? 0;
      int received = 0;
      final file = File(cheminLocal);
      final sink = file.openWrite();
      _progressParLivre[idBook] = 0.0;
      await for (final List<int> chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;

        if (totalBytes > 0) {
          double nouveauProgress = received / totalBytes;

          // --- CORRECTION SÉCURISÉE DU PROGRESS ---
          double ancienProgress = _progressParLivre[idBook] ?? 0.0;
          _progressParLivre[idBook] = nouveauProgress;

          // Notifier seulement si on a progressé de plus de 2% pour économiser l'UI
          if ((nouveauProgress * 50).floor() > (ancienProgress * 50).floor()) {
            notifyListeners();
          }
        }
      }

      await sink.flush();
      await sink.close();
      //client.close();

      final int taille = await file.length();
      if (taille == 0) {
        if (await file.exists()) await file.delete();
        _finirTelechargement(idBook, succes: false, erreur: 'Fichier vide après téléchargement');
        return;
      }

      // --- SÉCURISATION DES DONNÉES SQL ---
      final DetailleBookModel bookLocal = DetailleBookModel(
        id              : idBook,
        titre           : detail.bookTitle      ?? 'Sans titre',
        couverture      : detail.bookBlanket     ?? '',
        description     : detail.description     ?? '',
        titre_categorie : detail.categoryTitle   ?? '',
        est_pysique     : detail.isPhysic        ?? false,
        est_electronique: extension == 'pdf' ? '1' : '0',
        est_audio       : detail.isAudio         ?? false,
        nombre_jaime    : detail.numberLike      ?? 0,
        nombre_no_jaime : detail.numberNoLike    ?? 0,
        nombre_subscribe: detail.numberSubscribe ?? 0,
        nombre_vue      : detail.numberView      ?? 0,
        fichier         : cheminLocal,
      );

      // Sauvegarde en base (assurez-vous que 'numero' n'est pas nul)
      final String numSecurise = (numero != null && numero.isNotEmpty) ? numero : "0000";

      await DatabaseHelper.instance.saveBookTelecharge(
          bookLocal, cheminLocal, numSecurise);

      await chargerLivresLocaux();

      _dejaTelechage[idBook] = true;
      _finirTelechargement(idBook, succes: true);
      debugPrint("✅ Téléchargé avec succe");

    } catch (e) {
      debugPrint("❌ Erreur téléchargement : $e");
      _finirTelechargement(idBook, succes: false, erreur: e.toString());
    }
  }
  */
  Future<void> _lancerTelechargementBackground(
      BookDetailDto detail, String idBook) async
  {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String dossierLivres = '${dir.path}/livres';
      await Directory(dossierLivres).create(recursive: true);

      final String extension = _getExtension(detail);
      final String url = _getUrlFichier(detail);

      if (extension.isEmpty || url.isEmpty) {
        _finirTelechargement(idBook, succes: false, erreur: 'Lien ou format invalide');
        return;
      }

      final String cheminLocal = '$dossierLivres/${idBook}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      if (_token.isEmpty) {
        await recupere_tocken();
      }

      debugPrint("URL : $url");
      debugPrint("Token : $_token");

      final dio = Dio();

      // Configuration des headers
      dio.options.headers['Authorization'] = 'Bearer $_token';

      // Utilisation de dio.download avec onReceiveProgress (plus simple et sûr)
      final response = await dio.download(
        url,
        cheminLocal,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double nouveauProgress = received / total;
            double ancienProgress = _progressParLivre[idBook] ?? 0.0;

            _progressParLivre[idBook] = nouveauProgress;

            // Rafraîchir l'UI tous les 2%
            if ((nouveauProgress * 50).floor() > (ancienProgress * 50).floor()) {
              notifyListeners();
            }
          }
        },
      );

      if (response.statusCode != 200) {
        _finirTelechargement(idBook, succes: false, erreur: 'Erreur serveur (${response.statusCode})');
        return;
      }

      final file = File(cheminLocal);
      final int taille = await file.length();

      if (taille == 0) {
        if (await file.exists()) await file.delete();
        _finirTelechargement(idBook, succes: false, erreur: 'Fichier vide après téléchargement');
        return;
      }

      // --- SAUVEGARDE SQL ---
      final DetailleBookModel bookLocal = DetailleBookModel(
        id              : idBook,
        titre           : detail.bookTitle      ?? 'Sans titre',
        couverture      : detail.bookBlanket     ?? '',
        description     : detail.description     ?? '',
        titre_categorie : detail.categoryTitle   ?? '',
        est_pysique     : detail.isPhysic        ?? false,
        est_electronique: extension == 'pdf' ? '1' : '0',
        est_audio       : detail.isAudio         ?? false,
        nombre_jaime    : detail.numberLike      ?? 0,
        nombre_no_jaime : detail.numberNoLike    ?? 0,
        nombre_subscribe: detail.numberSubscribe ?? 0,
        nombre_vue      : detail.numberView      ?? 0,
        fichier         : cheminLocal,
      );

      final String numSecurise = (numero != null && numero!.isNotEmpty) ? numero! : "0000";

      await DatabaseHelper.instance.saveBookTelecharge(
          bookLocal, cheminLocal, numSecurise);

      await chargerLivresLocaux();

      _dejaTelechage[idBook] = true;
      _finirTelechargement(idBook, succes: true);
      debugPrint("✅ Téléchargé avec succès : $cheminLocal");

    } catch (e) {
      debugPrint("❌ Erreur téléchargement : $e");
      _finirTelechargement(idBook, succes: false, erreur: "Erreur réseau ou accès fichier");
    }
  }
*/
  void _finirTelechargement(String idBook, {
    required bool succes,
    String erreur = '',
  }) {
    _enCoursParLivre[idBook]  = false;
    if (succes) {
      _progressParLivre[idBook] = 1.0;
      _actionMessage = 'telecharge_ok';
    } else {
      _progressParLivre.remove(idBook);
      _actionMessage = 'erreur_$idBook';
      _errorMessage  = erreur;
    }
    notifyListeners();
  }

// ══════════════════════════════════════════════════════════════════════
// RÉSERVATION — avec jours restants
// ══════════════════════════════════════════════════════════════════════
  Future<void> reserverLivre(String idBook,String dure) async {
    if (_reserveParLivre[idBook] == true) return;

    // Déjà réservé ?
    final bool dejaReserve = await DatabaseHelper.instance
        .isReserve(idBook, numero);
    if (dejaReserve) {
      _actionMessage = 'deja_reserve';
      notifyListeners();
      return;
    }

    _reserveParLivre[idBook] = true;
    notifyListeners();

    try {
      final String result = await repositorie.reserverLivre(numero, idBook);

      if (result == 'success') {
        final DateTime maintenant = DateTime.now();
        await DatabaseHelper.instance.saveReservation(idBook, numero,dure);
        _statutReservation[idBook] = 'en_attente';
        _dateReservation[idBook]   = maintenant;
        _actionMessage = 'reserve_ok';
      } else {
        _actionMessage = result;
      }
    } catch (e) {
      _actionMessage = _mapError(e.toString());
    } finally {
      _reserveParLivre[idBook] = false;
      notifyListeners();
    }
  }

// ── Jours restants (durée emprunt = 14 jours par défaut) ─────────────
  int joursRestants(String idBook, {int dureeEmprunt = 14}) {
    final DateTime? date = _dateReservation[idBook];
    if (date == null) return 0;
    final DateTime expiration = date.add(Duration(days: dureeEmprunt));
    final int jours = expiration.difference(DateTime.now()).inDays;
    return jours < 0 ? 0 : jours;
  }

  double progressionReservation(String idBook, {int dureeEmprunt = 14}) {
    final DateTime? date = _dateReservation[idBook];
    if (date == null) return 0.0;
    final int ecoule = DateTime.now().difference(date).inDays;
    return (ecoule / dureeEmprunt).clamp(0.0, 1.0);
  }

// ── URLs et extensions ────────────────────────────────────────────────

// ── Ouvrir un fichier téléchargé ──────────────────────────────────────
 /*
  Future<String?> getCheminFichierLocal(String idBook, bool type_pdf, bool type_audio) async {
    try {
      final livres = await DatabaseHelper.instance.getBooksTelecharges(numero);

      // Correction de la logique de recherche avec firstWhere
      final livre = livres.firstWhere(
            (l) {
          if (type_pdf) return l.id == idBook && l.is_dowlonded_pdf == 1;
          if (type_audio) return l.id == idBook && l.is_dowlonded_audio == 1;
          return false;
        },
        orElse: () => throw Exception('Non trouvé'),
      );

      final file = File(livre.fichier);
      if (await file.exists()) {
        return livre.fichier;
      } else {
        // Fichier supprimé manuellement du téléphone → on nettoie la DB
        await DatabaseHelper.instance.deleteBookTelecharge(idBook, numero);
        return null;
      }
    } catch (_) {
      return null;
    }
  }
 */
  Future<String?> getCheminFichierLocal(String idBook, bool type_pdf, bool type_audio) async {
    try {
      final livres = await DatabaseHelper.instance.getBooksTelecharges(numero);

      // On cherche le livre.
      // Note : On utilise ".where(...).firstOrNull" pour éviter l'exception de firstWhere
      final livre = livres.firstWhere(
            (l) {
          if (type_pdf) {
            // Correction ici : vérification si c'est 1 (int) ou true (bool)
            return l.id == idBook && (l.is_dowlonded_pdf == 1 || l.is_dowlonded_pdf == true);
          }
          if (type_audio) {
            return l.id == idBook && (l.is_dowlonded_audio == 1 || l.is_dowlonded_audio == true);
          }
          return false;
        },
        orElse: () => throw Exception('Non trouvé'),
      );

      final file = File(livre.fichier);
      if (await file.exists()) {
        return livre.fichier;
      } else {
        await DatabaseHelper.instance.deleteBookTelecharge(idBook, numero);
        return null;
      }
    } catch (e) {
      print("Erreur chargement local : $e"); // Pour voir l'erreur exacte au cas où
      return null;
    }
  }

// ── Vérifier état réservation ─────────────────────────────────────────
  Future<bool> estReserve(String idBook) async {
    return DatabaseHelper.instance.isReserve(idBook, numero);
  }
  //___________________________________________________
  // ══════════════════════════════════════════════════════════════════════
  // CHARGEMENT DES LISTES
  // ══════════════════════════════════════════════════════════════════════
  Future<void> chargerLivres() async {
    _startLoading();
    try {
      _livres = await repositorie.livres(appState.numeroUtilisateur);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }
/*
  Future<void> chargerRecomandes() async {
    try {
      _livresRecomandes = await repositorie.livreRecomander(numero, version);
      notifyListeners();
    } catch (e) {
      debugPrint("Recomandés : ${e.toString()}");
    }
  }
*/
  Future<void> chargerElectroniques() async {
    _startLoading();
    try {
      _livresElectro = await repositorie.livreElectronique(numero);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  Future<void> chargerAudio() async {
    _startLoading();
    try {
      _livresAudio = await repositorie.livreAudio(numero);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  Future<void> chargerEmpruntes() async {
    _startLoading();
    try {
      _livresEmpruntes = await repositorie.livreEmprunter(numero);
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // DÉTAIL D'UN LIVRE
  // ══════════════════════════════════════════════════════════════════════
  Future<void> chargerDetail(String numero,String idBook,) async {
    _isLoadingDetail = true;
    _errorMessage    = '';
    notifyListeners();
    try {
      await enregistrerVue(idBook);
      _detailLivre = await repositorie.detail( numero ,idBook);
      estReserve( idBook);
      verifierEtatFichier(idBook);
     //_isTelecharge_pdf = await DatabaseHelper.instance.isBookTelecharge_pdf(idBook, numero);
      //_isReserve = await DatabaseHelper.instance.isReserve(idBook, numero);
      // On enregistre automatiquement la vue
    } catch (e) {
      _errorMessage = _mapError(e.toString());
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // ACTIONS (like / dislike / vue / abonner / commenter)
  // ══════════════════════════════════════════════════════════════════════
  Future<void> enregistrerVue(String idBook) async {
    try {
      await repositorie.vue(numero, idBook);
      //_actionMessage = 'vue_ok';
      //notifyListeners();

    } catch (e) {
      debugPrint("Vue non enregistrée : $e");
    }
  }

  Future<void> likerLivre(String idBook) async {
    try {

      final result = await repositorie.like(numero, idBook);
       if (result == 'ok') {
         _liker=true;
       }
      _actionMessage = result == 'ok' ? 'like_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  Future<void> dislikerLivre(String idBook) async {
    try {
      final result = await repositorie.dislike(numero, idBook);
      if (result == 'ok') {
        _noliker=true;
      }
      _actionMessage = result == 'ok' ? 'dislike_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  Future<void> abonnerLivre(String idBook) async {
    try {
      final result = await repositorie.abonner(numero, idBook);
      if (result == 'ok') {
        _subscribe=true;
      }
      _actionMessage = result == 'ok' ? 'abonne_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  Future<void> commenterLivre(String idBook, String texte) async {
    if (texte.trim().isEmpty) {
      _errorMessage = 'Le commentaire ne peut pas être vide.';
      notifyListeners();
      return;
    }
    try {
      final result = await repositorie.comment(numero, idBook, texte.trim());
      _actionMessage = result == 'success' ? 'comment_ok' : result;
      notifyListeners();
    } catch (e) {
      _errorMessage = _mapError(e.toString());
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // TÉLÉCHARGEMENT & STOCKAGE LOCAL
  // ══════════════════════════════════════════════════════════════════════

   Future<void> chargerLivresLocaux() async {
    try {
      _livresLocaux = await DatabaseHelper.instance.getBooksTelecharges( numero);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur chargement local : $e");
    }
  }

  /// Supprimer un livre téléchargé (fichier + base locale)
  Future<void> supprimerLivreLocal(DetailleBookModel book,String numero) async {
    try {
      // 1. Supprimer le fichier physique
      final file = File(book.fichier);
      if (await file.exists()) {
        await file.delete();
        debugPrint("🗑️ Fichier supprimé : ");
      }
      final image = File(book.couverture);
      if (await image.exists()) {
        await image.delete();
        debugPrint("🗑️ image supprimé : ");
      }

      // 2. Supprimer de la base SQLite
      await DatabaseHelper.instance.deleteBookTelecharge(book.id, numero);
      // 3. Rafraîchir la liste
      await chargerLivresLocaux();
      notifyListeners();

    } catch (e) {
      _errorMessage = "Erreur lors de la suppression : ${e.toString()}";
      notifyListeners();
    }
  }


  /// Vérifier si un livre est disponible hors-ligne
  /*
  Future<bool> estDisponibleHorsLigne(String idBook) async {
    return DatabaseHelper.instance.isBookTelecharge(idBook, numero);
  }
*/
  // ══════════════════════════════════════════════════════════════════════
  // UTILITAIRES PRIVÉS
  // ══════════════════════════════════════════════════════════════════════
  void _startLoading() {
    _isLoading    = true;
    _errorMessage = '';
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearActionMessage() {
    _actionMessage = '';
  }

  String _mapError(String error) {
    final e = error.toLowerCase();
    if (e.contains('pasdeconnexion') || e.contains('socketexception')) {
      return 'Pas de connexion internet. Vérifiez votre réseau.';
    }
    if (e.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre.';
    }
    if (e.contains('format')) {
      return 'Réponse serveur invalide.';
    }
    return 'Une erreur inattendue est survenue.';
  }
}


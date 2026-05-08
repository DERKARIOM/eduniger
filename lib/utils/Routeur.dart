import 'package:eduniger/features/accueil/views/acceuil_view.dart';
import 'package:eduniger/utils/pages/bibliotheque_page.dart';
import 'package:eduniger/utils/pages/eduna_page.dart';
import 'package:eduniger/utils/pages/librairie_page.dart';
import 'package:eduniger/utils/pages/principal.dart';
import 'package:flutter/cupertino.dart';

import '../features/lecteur_audio/views/lecteur_audio_view.dart';
import '../features/lecteur_pdf/views/lecteur_pdf_view.dart';
import '../features/livres/views/detail_book_view.dart';
import '../features/utilisateurs/views/user_view_login.dart';



abstract class Routeur {
  static const String routeInitiale = "/login";

  static final Map<String,WidgetBuilder> route={
    routeInitiale:(context) => const user_view_login(),
    "/logine":(context) => const user_view_login(),
    "/accueil":(context) => const AccueilView(),
    "/librairie":(context) => const LibrairiePage(),
    "/eduna":(context) => const EdunaPage(),
    "/bibliotheque":(context) => const BibliothequePage(),
    '/home'         : (context) => const AccueilView(),
    '/detail_livre' : (context) => const DetailBookView(),
    "/mainPage":(context) => const MainPage(),
    '/lecteur_audio' : (_) => const LecteurAudioView(),
    '/lecteur_pdf'   : (_) => const LecteurPdfView(),


  };

}


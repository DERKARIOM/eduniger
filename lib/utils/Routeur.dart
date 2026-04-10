import 'package:flutter/cupertino.dart';

import '../features/utilisateurs/views/user_view_login.dart';
import '../pages/bootomBart/accueil_page.dart';
import '../pages/bootomBart/bibliotheque_page.dart';
import '../pages/bootomBart/eduna_page.dart';
import '../pages/bootomBart/librairie_page.dart';
import '../pages/bootomBart/main_page.dart';


abstract class Routeur {
  static const String routeInitiale = "/login";
  static final Map<String,WidgetBuilder> route={
    routeInitiale:(context) => const user_view_login(),
    "/accueil":(context) => const AccueilPage(IdNumber: '', Version: '',),
    "/librairie":(context) => const LibrairiePage(),
    "/eduna":(context) => const EdunaPage(),
    "/bibliotheque":(context) => const BibliothequePage(),
   // "/detailBook":(context) => const DetailBookPage(),
    "/mainPage":(context) => const MainPage(),
    //"/detailAuthor":(context) => const DetailAuthorPage(),
    //"/detailUser":(context) => const DetailUserPage(),
   // "/detailBookUser":(context) => const DetailBookUserPage(),
   // "/detailStructureUser":(context) => const DetailStructureUserPage(),
   // "/detailAuthorUser":(context) => const DetailAuthorUserPage(),

  };

}


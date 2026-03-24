import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:eduniger/pages/bootomBart/accueil_page.dart';
import 'package:eduniger/services/login_api.dart';
import 'package:flutter/material.dart';

import '../../infoApp/versionAPP_tocken.dart';
import '../../localDataBase/sqlflitEduniger.dart';
import '../../models/modelUser.dart';
import 'bibliotheque_page.dart';
import 'eduna_page.dart';
import 'librairie_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, }) : super(key: key);
  //User? user
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String idNumber = "";
  String version = ""; // Initialisé à vide
  bool isLoading = true; // Pour attendre que les données soient prêtes

  @override
  void initState() {
    super.initState();
    _initData(); // Appeler l'initialisation au démarrage
  }

  // Fonction pour charger toutes les infos nécessaires
  Future<void> _initData() async {
    //final userData = await DatabaseHelper.instance.getUser();
    final idUser = await DatabaseHelper.instance.getIdNumber();
    final appVersion = await AppInfo.getAppVersion();

    setState(() {
      idNumber = idUser.toString();
      version = appVersion;
      isLoading = false; // Le chargement est fini
    });
  }

  // AU LIEU d'une liste de widgets fixe, on utilise une fonction
  // qui retourne le widget selon l'index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return AccueilPage(IdNumber: idNumber, Version: version);
      case 1:
        return LibrairiePage();
      case 2:
        return EdunaPage();
      case 3:
        return BibliothequePage();
      default:
        return AccueilPage(IdNumber: idNumber, Version: version);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Future<void> _handleLogout(BuildContext context) async {
    // 1. Supprimer les données locales
    await DatabaseHelper.instance.logout();

    // 2. Rediriger vers la page de login et supprimer tout l'historique de navigation
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top:5, left: 10, right: 10),
              margin: const EdgeInsets.only(top: 6, left: 15,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
              margin: const EdgeInsets.only(right: 5),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche un livre',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: const Icon(Icons.mic, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
            ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child:  Icon(Icons.notifications_none_sharp, size: 30,),

                  ),
                  const SizedBox(width: 5),
                  IconButton(onPressed: (){

                    _handleLogout(
                      context,
                    );

                  },
                      icon:Icon(Icons.menu_sharp, size: 30,))



                ],
              ),
            ),
          ),
        ),
      ),
      body: _getPage(_selectedIndex),
      //utilisation du pachage ConvexAppBart pour la navigation
      bottomNavigationBar: ConvexAppBar(
        color: Colors.black,
        activeColor: Colors.green,

    items: [
    TabItem(icon: Image.asset('assets/icon_bootomBart/home.png',color: Colors.green,)  , title: 'Accueil'),
    TabItem(icon: Image.asset('assets/icon_bootomBart/livre.png',color: Colors.green,), title: 'Librairie'),
    TabItem(icon: Image.asset('assets/icon_bootomBart/ia.png',color: Colors.green,), title: 'Eduna'),
    TabItem(icon: Image.asset('assets/icon_bootomBart/biblio.png',color: Colors.green,), title: 'Biliothèque'),
    ],
    //index par defaut
    initialActiveIndex: _selectedIndex,
    //style de la navigation il y a plusieur
    style: TabStyle.flip,
    height: 60,
    //taille du cercle
    curveSize: 0,

    backgroundColor: Colors.white,
    onTap:_onItemTapped,
    )
    );


  }
}

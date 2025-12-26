import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:eduniger/pages/bootomBart/accueil_page.dart';
import 'package:eduniger/services/login_api.dart';
import 'package:flutter/material.dart';

import '../../models/modelUser.dart';
import 'bibliotheque_page.dart';
import 'eduna_page.dart';
import 'librairie_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, User? user}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Liste des pages à afficher selon l'onglet sélectionné
  final List<Widget> _pages = [
    AccueilPage(),
    LibrairiePage(),
    EdunaPage(),
    BibliothequePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
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
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: const AssetImage('assets/images/user.png'),

                  ),



                ],
              ),
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
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

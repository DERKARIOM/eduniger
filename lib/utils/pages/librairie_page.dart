import 'package:flutter/material.dart';

import '../../features/categorie/views/categorie.dart';
import '../../features/livres/views/livre.dart';
import '../../features/structures/views/structure.dart';


class LibrairiePage extends StatefulWidget {
  const LibrairiePage({super.key});

  @override
  State<LibrairiePage> createState() => _LibrairiePageState();
}

class _LibrairiePageState extends State<LibrairiePage> {
  List<Widget>  _pageLibrairie =[
    Livre(),
    Categorie(),
     StructurePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(
        length: _pageLibrairie.length,
        initialIndex: 0,
        animationDuration: const Duration(milliseconds: 300),
        child: Scaffold(
          backgroundColor: Colors.white,
            body: Column(
              children: [
                const TabBar(
                  //indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.green,
                  tabs: [
                    // Corrections orthographiques pour la clarté
                    Tab(text: "Livre"),
                    Tab(text: "Catégorie"),
                    Tab(text: "Structure"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: _pageLibrairie,
                  ),
                )
              ],
            )),
      );


  }
}

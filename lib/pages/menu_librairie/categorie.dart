import 'package:flutter/material.dart';

import '../../models/modelCategorie.dart';
class Categorie extends StatefulWidget {
  const Categorie({super.key});

  @override
  State<Categorie> createState() => _CategorieState();
}

class _CategorieState extends State<Categorie> {
  List<MCategorie> mcategorie = [
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Histoire et culture',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      bookNumber: '123',
    ),
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Développement personnel',
      description: 'Description de la structure',
      isAdhere: false,),
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Développement professionnel',
      description: 'Description de la structure',
      isAdhere: false,),
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Développement professionnel',
      description: 'Description de la structure',
      isAdhere: false,),
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Histoire et culture',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      bookNumber: '123',
    ),
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Développement personnel',
      description: 'Description de la structure',
      isAdhere: false,),
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Développement professionnel',
      description: 'Description de la structure',
      isAdhere: false,),
    MCategorie(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Développement professionnel',
      description: 'Description de la structure',
      isAdhere: false,),





  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: ListView.builder(
          shrinkWrap: true, // Indique à la ListView de prendre seulement la place nécessaire
          //physics: const NeverScrollableScrollPhysics(), // Empêche cette ListView de défiler (le SingleChildScrollView s'en charge)
          itemCount: mcategorie.length,
          itemBuilder: (context, index) {
            final cat = mcategorie[index];
            return  ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                leading: CircleAvatar(
                  radius: 35, // Augmenté pour un meilleur aspect
                  backgroundImage: AssetImage(cat.cover ?? 'assets/images/placeholder.png'),
                ),
                title: Text(
                  cat.name ?? 'Non spécifier',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                );
          }),
    );
  }
}

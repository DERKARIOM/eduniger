import 'package:flutter/material.dart';

import '../../models/modelBook.dart';
class Livre extends StatefulWidget {
  const Livre({super.key});

  @override
  State<Livre> createState() => _LivreState();
}

class _LivreState extends State<Livre> {
  List<Book> couverture = [
    Book(
      id: '1',
      cover: 'assets/images/img_add_cover.png',
      title: "AES: L'Afrique qui se lève",
      structure: 'OpenLab',
      category: 'Histoire et Culture',
      ispdf: true,

    ),
    Book(
      id: '2',
      cover: 'assets/images/img_wait_cover_book.png',
      title: 'Dominez le Futur',
      structure: 'OpenLab',
      category: 'développement personnel',
      ispdf: true,

    ),
    Book(
      id: '3',
      cover: 'assets/images/img_add_cover.png',
      title: "Le Pouvoir extraordinaire de l'humanité chez les dirigeants",
      structure: 'CAJEC',
      category: 'développement personnel',
      ispdf: true,
      isphisique: true,


    ),
    Book(
      id: '4',
      cover: 'assets/images/img_wait_cover_book.png',
      title: "Il suffit d'une décision pour changer de vie",
      structure: 'CAJEC',
      category: 'développement personnel',
      ispdf: true,
      isphisique: true,


    ),
    Book(
      id: '1',
      cover: 'assets/images/img_add_cover.png',
      title: "AES: L'Afrique qui se lève",
      structure: 'OpenLab',
      category: 'Histoire et Culture',
      ispdf: true,

    ),
    Book(
      id: '2',
      cover: 'assets/images/img_wait_cover_book.png',
      title: 'Dominez le Futur',
      structure: 'OpenLab',
      category: 'développement personnel',
      ispdf: true,

    ),
    Book(
      id: '3',
      cover: 'assets/images/img_add_cover.png',
      title: "Le Pouvoir extraordinaire de l'humanité chez les dirigeants",
      structure: 'CAJEC',
      category: 'développement personnel',
      ispdf: true,
      isphisique: true,


    ),
    Book(
      id: '4',
      cover: 'assets/images/img_wait_cover_book.png',
      title: "Il suffit d'une décision pour changer de vie",
      structure: 'CAJEC',
      category: 'développement personnel',
      ispdf: true,
      isphisique: true,


    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 30,top: 20,right: 5),
        itemCount: couverture.length,
          itemBuilder: (context, index) {

            final book = couverture[index];

            return Padding(
              // Ajoute un peu d'espace entre chaque élément de la liste
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligne les éléments en haut
                children: [
                  // --- 1. L'image de couverture ---
                  Container(
                    width: 60,
                    height: 95, // La hauteur sera maintenant respectée !
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        book.cover!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16), // Espace horizontal entre l'image et le texte

                  // --- 2. La colonne pour le titre et le sous-titre ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligne le texte à gauche
                      children: [
                        const SizedBox(height: 15), // Petit espace pour centrer verticalement
                        Text(
                          book.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          // Permet au texte de passer à la ligne s'il est trop long
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8), // Espace entre le titre et le sous-titre
                        Text(
                          "${book.structure} : ${book.category}",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8), // Espace entre le sous-titre et le bouton
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            book.isphisique ==true ?Icon(Icons.menu_book_sharp,color: Colors.green,size: 15,):SizedBox(),
                            const SizedBox(width: 8),
                            book.ispdf ==true ?Icon(Icons.picture_as_pdf,color: Colors.green,size: 15,):SizedBox(),
                            const SizedBox(width: 8),
                            book.isaudio ==true ?Icon(Icons.audiotrack,color: Colors.green,size: 15,):SizedBox(),
                            const SizedBox(width: 8),
                            Icon(Icons.thumb_up_off_alt,color: Colors.green,size: 15,),
                            Text("  10",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                            const SizedBox(width:15),
                            Icon(Icons.visibility_sharp,color: Colors.green,size: 15,),
                            Text("  40",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),)


                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

      )
    );
  }
}

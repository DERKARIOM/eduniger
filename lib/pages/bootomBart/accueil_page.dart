import 'dart:async';

import 'package:eduniger/models/modelBook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/modelAutheur.dart';
import '../../models/modelStructure.dart';
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  List<String> publications = [
    'assets/pub/1.png',
    'assets/pub/2.png',
    'assets/pub/6.png',
  ];
  List<Book> couverture = [
    Book(
      id: '1',
      cover: 'assets/images/img_add_cover.png',
    ),
    Book(
      id: '2',
      cover: 'assets/images/img_wait_cover_book.png',
    ),
    Book(
      id: '3',
      cover: 'assets/images/img_add_cover.png',
    ),
    Book(
      id: '4',
      cover: 'assets/images/img_wait_cover_book.png',
    )
  ];
  List<Structure> structure = [
    Structure(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'OpenLab',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      adhererNumber: '123',
      bookNumber: '456',
      admin: 'Nom de l\'administrateur',

    ),
    Structure(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Kit TD',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      adhererNumber: '123',
      bookNumber: '456',
      admin: 'Nom de l\'administrateur',

    ),
    Structure(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Cajec',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      adhererNumber: '123',
      bookNumber: '456',
      admin: 'Nom de l\'administrateur',

    ),
    Structure(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Kit TA',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      adhererNumber: '123',
      bookNumber: '456',
      admin: 'Nom de l\'administrateur',

    ),
    Structure(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Concours EAMAC',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      adhererNumber: '123',
      bookNumber: '456',
      admin: 'Nom de l\'administrateur',

    ),
    Structure(
      id: '1',
      cover: 'assets/images/add_auteurs.png',
      name: 'Kit BEPC',
      description: 'Description de la structure',
      isAdhere: false,
      banner: 'assets/images/add_auteurs.png',
      author: 'Nom de l\'auteur',
      adhererNumber: '123',
      bookNumber: '456',
      admin: 'Nom de l\'administrateur',

    ),

  ];
  List<Author> auteurs = [
    Author(
      name: 'Sembene',
      firstName: 'Sembene',
      profile: 'assets/images/user.png',
      isAdmin: false,
    ),
    Author(
      name: 'Sembene',
      firstName: 'Sembene',
      profile: 'assets/images/user.png',
      isAdmin: false,),
    Author(
      name: 'Sembene',
      firstName: 'Sembene',
      profile: 'assets/images/user.png',
      isAdmin: false,
    ),
    Author(
      name: 'Sembene',
      firstName: 'Sembene',
      profile: 'assets/images/user.png',
      isAdmin: false,),
    Author(
      name: 'Sembene',
      firstName: 'Sembene',
      profile: 'assets/images/user.png',
      isAdmin: false,
    ),
    Author(
      name: 'Sembene',
      firstName: 'Sembene',
      profile: 'assets/images/user.png',
      isAdmin: false,),



  ];
// Auto-scroll de publications

  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void _autoSwitch() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 4)); // temps d'affichage

      _currentPage++;

      if (_currentPage >= publications.length) {
        _currentPage = 0;
      }

      _pageController.jumpToPage(_currentPage); // saut instantané ❗
    }
  }

  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
// fin  Auto-scroll de publications

  @override
  void initState() {
    super.initState();
    _autoSwitch();
    /*
     _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.offset + 1.2, // vitesse
        );

        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        }
      }
    });
     */
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
          //Les publications
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: publications.length,
              physics: const NeverScrollableScrollPhysics(), // optionnel
              itemBuilder: (context, index) {
                return
                  Container(

                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),

                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),


                  ),
                  child:ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      publications[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                );
              },
            ),
          ),

          /*
            Container(
              height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
              //width: 300,
              child:
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: publications.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Image.asset(
                      publications[index],
                      fit: BoxFit.cover,
                    ),
                  ).animate(delay: (index * 100).ms)
                      .fadeIn()
                      .slideX(begin: 0.3, end: 0);

                },
              )

            ),
            */
            const SizedBox(height: 30),
            //ajouter un contenu
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/images/add_auteurs.png'),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                      .moveY(
                    begin: 0,
                    end: -15, // monte de 15 pixels
                    duration: 800.ms,
                    curve: Curves.easeInOut,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ajouter un contenu",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                        const Text("Créez librement"),

                      ],
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,

                      borderRadius: BorderRadius.circular(30),
                    ),


                      child: TextButton(onPressed: (){}, child: Text("Ajouter",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.white),)))
                ],
              ),
            ),
            //const SizedBox(height: 10),
            //voir les livres
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Text('Recomandés',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  Spacer(),
                  const Text('Voir plus',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green),),



                ],

              ),
            ),
          //liste des livres
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: couverture.length < 6 ? couverture.length : 7,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),


                    ),
                    child:ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        couverture[index].cover!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 150,
                      ),
                    ),
                  ).animate(delay: (index * 100).ms)
                      .fadeIn();

                }
              ),


            ),
        // voir des structures
           Padding(
          padding:  const EdgeInsets.all(10),
          child: Row(
          children: [
            const Text('Structure', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Spacer(), // Spacer est plus propre qu'un Expanded avec un SizedBox
            const Text('Voir plus', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
          //liste des structures
           ListView.builder(
          shrinkWrap: true, // Indique à la ListView de prendre seulement la place nécessaire
          physics: const NeverScrollableScrollPhysics(), // Empêche cette ListView de défiler (le SingleChildScrollView s'en charge)
          itemCount: structure.length < 6 ? structure.length : 6, // J'ai corrigé votre logique ici pour afficher jusqu'à 6 éléments
          itemBuilder: (context, index) {
            return Container(
              // Le ListTile est plus adapté pour ce layout
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                leading: CircleAvatar(
                  radius: 35, // Augmenté pour un meilleur aspect
                  backgroundImage: AssetImage(structure[index].cover),
                ),
                title: Text(
                  structure[index].name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${structure[index].bookNumber} livres",
                  style: TextStyle(fontSize: 13),
                ),
                trailing: Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    color: structure[index].isAdhere ? Colors.black45 : Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      structure[index].isAdhere ? "Adhéré" : "S'adhérer", // Texte dynamique
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
            SizedBox(height: 5,),
            // voir des auteurs
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Text('Auteurs',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  Expanded(child: const SizedBox(width: 10),),
                  const Text('Voir plus',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green),),



                ],

              ),
            ),
           SizedBox(height: 5,),
        //liste des auteurs
      SizedBox(
          height: 110,

      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: auteurs.length < 6 ? auteurs.length : 6,
          itemBuilder: (context, index) {
            return
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(auteurs[index].profile!),
                  ),
                  const SizedBox(height: 5,),
                  Text(auteurs[index].name,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),




                ],
                            ),
              );
          })
      ),
          ],
      )
      )
    );
  }
}

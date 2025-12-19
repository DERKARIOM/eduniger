import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
          SizedBox(
            height: 170,
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
            const SizedBox(height: 10),
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Ajouter un contenu",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                      const Text("Créez librement"),
                      
                    ],
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


          ],
        ),
      )
    );
  }
}

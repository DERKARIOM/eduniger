import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Container(
              margin: EdgeInsets.only(left: 10,right: 10),
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset('assets/images/DUNIGER.png',fit: BoxFit.cover,),

            ),
            const SizedBox(height: 10),
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/images/user.png'),
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

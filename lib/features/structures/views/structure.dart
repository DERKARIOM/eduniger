import 'package:flutter/material.dart';

import '../model/structure_model.dart';



class StructurePage extends StatefulWidget {
  const StructurePage({super.key});

  @override
  State<StructurePage> createState() => _StructureState();
}

class _StructureState extends State<StructurePage> {
  List<Structure> structure = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
          shrinkWrap: true, // Indique à la ListView de prendre seulement la place nécessaire
          //physics: const NeverScrollableScrollPhysics(), // Empêche cette ListView de défiler (le SingleChildScrollView s'en charge)
          itemCount: structure.length,
          itemBuilder: (context, index) {
            return Container(
              // Le ListTile est plus adapté pour ce layout
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                leading: CircleAvatar(
                  radius: 35, // Augmenté pour un meilleur aspect
                  backgroundImage: NetworkImage(
                    structure[index].logo??'',
                  ),
                ),
                title: Text(
                  structure[index].name??'',
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
    );
  }
}

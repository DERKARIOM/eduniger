import 'package:flutter/material.dart';
class LibrairiePage extends StatefulWidget {
  const LibrairiePage({super.key});

  @override
  State<LibrairiePage> createState() => _LibrairiePageState();
}

class _LibrairiePageState extends State<LibrairiePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Bienvenue sur la bibliothèque!"),
      ),
    );
  }
}

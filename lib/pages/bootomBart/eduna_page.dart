import 'package:flutter/material.dart';

class EdunaPage extends StatefulWidget {
  const EdunaPage({super.key});

  @override
  State<EdunaPage> createState() => _EdunaPageState();
}

class _EdunaPageState extends State<EdunaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Bienvenue sur Eduna!"),
      ),
    );
  }
}

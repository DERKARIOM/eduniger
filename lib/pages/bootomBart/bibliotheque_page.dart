import 'package:flutter/material.dart';

import '../../localDataBase/sqlflitEduniger.dart';

class BibliothequePage extends StatefulWidget {
  const BibliothequePage({super.key});

  @override
  State<BibliothequePage> createState() => _BibliothequePageState();
}

class _BibliothequePageState extends State<BibliothequePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }
  // Variables pour stocker les données de l'utilisateur
  String userName = '';
  String userEmail = '';
  String profilePic = '';
  //Fonction pour lire SQLITE
  Future<void> _loadUserData() async {
    final userData = await DatabaseHelper.instance.getUser();

    if (userData != null) {
      String profile = userData['profile'] ?? '';

      // Si c'est juste le nom du fichier par défaut ou vide
      if (profile == "user.png" || profile.isEmpty) {
        profile = "";
      }
      // Si c'est une image personnalisée mais sans domaine
      else if (!profile.startsWith('http')) {
        profile = "https://eduniger.com/api/profiles/$profile";
      }
      setState(() {
        // 'name' et 'email' doivent correspondre aux noms des colonnes dans SQLITE
        userName = "${userData['firstName']} ${userData['name']}";
        userEmail = userData['email'];
        profilePic =  profile;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Column(
                 children: [
                Center(
                  child: Stack(
                    children: [

                      CircleAvatar(
                        radius:70,
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic) // Si l'URL existe
                            : const AssetImage('assets/images/user.png') as ImageProvider, // Image par défaut

                        //backgroundImage: const AssetImage('assets/images/user.png'),
                        //backgroundImage: AssetImage('assets/images/user.png'),
                      ),
                      // L'icône positionnée en bas à droite
                      Positioned(
                        bottom: -2,
                        right: 0,
                        child: Container(

                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10,),
                Text(userName,style: TextStyle(fontSize: 14,),),
                Text(userEmail),

              ],
          )

              ),
              SizedBox(height: 10,),
              Divider(),
              SizedBox(height: 10,),
              Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    const Text("Vos téléchargements"),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
              Divider(),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      _buildListTile(Icons.picture_as_pdf, "Vos Livres Electroniques", "4"),
                      _buildListTile(Icons.music_note, "Vos Livres Audios", "0"),
                      _buildListTile(Icons.picture_as_pdf, "Vos Livres Empruntés", "0"),
                      _buildListTile(Icons.menu, "Catégories", "0"),
                      _buildListTile(Icons.group, "Auteurs", "2"),
                    ],
                ),
              ),
              
            ],
          ),
        ),
        
      )
    );

  }

  // Fonction pour éviter de répéter le code des ListTile
  Widget _buildListTile(IconData icon, String title, String count) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 20,
        child: Icon(icon, color: Colors.black, size: 20),
      ),
      title: Text(title),
      trailing: Text(
        count,
        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

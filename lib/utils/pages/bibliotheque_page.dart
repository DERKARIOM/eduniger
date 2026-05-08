import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../appstate.dart';
import '../../features/livres/models/detaille_book_model.dart';
import '../../features/livres/view_models/book_view_model.dart';
import '../../localDataBase/sqlflitEduniger.dart';
/*
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
  static const String baseUrlProfile = 'https://eduniger.com/ressources/profile/';

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
                            ? NetworkImage( '${baseUrlProfile}${profilePic}') // Si l'URL existe
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
*/
class BibliothequePage extends StatelessWidget {
  const BibliothequePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(children: [

              // ── Profil utilisateur (depuis DB locale) ────────────────
              _buildProfil(),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              // ── Téléchargements ──────────────────────────────────────
              const Text('Vos téléchargements',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // ── Liste des livres locaux ──────────────────────────────
              vm.livresLocaux.isEmpty
                  ? _sectionVide('Aucun téléchargement')
                  : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.livresLocaux.length,
                  itemBuilder: (_, index) {
                    final livre = vm.livresLocaux[index];
                    return _cartelivreLocal(context, vm, livre);
                  },
                ),
              ),

              const Divider(height: 24),

              // ── Statistiques ─────────────────────────────────────────
              _buildListTile(
                Icons.picture_as_pdf, 'Livres Électroniques',
                '${vm.livresLocaux.where((l) => l.est_electronique == '1').length}',
              ),
              _buildListTile(
                Icons.audiotrack, 'Livres Audio',
                '${vm.livresLocaux.where((l) => l.est_audio).length}',
              ),
              _buildListTile(
                Icons.menu_book, 'Livres Empruntés', '0',
              ),
            ]),
          ),
        );
      },
    );
  }

  // ── Carte livre local ─────────────────────────────────────────────────
  Widget _cartelivreLocal(
      BuildContext context, BookViewModel vm, DetailleBookModel livre) {
    //print('la couverture ${livre.couverture}');
    bool pdf = livre.is_dowlonded_pdf;
    bool audio = livre.is_dowlonded_audio;
    return Stack(children: [
      GestureDetector(
        onTap: () => _ouvrirFichier(context, vm, livre,pdf,audio),
        child: Container(
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: livre.couverture.isNotEmpty
                  ? Image.file(
                File(livre.couverture), // livre.couverture doit être un chemin comme "/data/user/0/..."
                width: 120,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _iconeLivre(livre),
              )/*Image.network(
                '${AppState.baseUrlCover}${livre.couverture}',
                width: 120, height: 140, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _iconeLivre(livre),
              )*/
                  : _iconeLivre(livre),
            ),
            const SizedBox(height: 4),
            Text(livre.titre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ]),
        ),
      ),
      // Bouton supprimer
      Positioned(
        top: 0, right: 0,
        child: GestureDetector(
          onTap: () => _confirmerSuppression(context, vm, livre),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ),
      ),
    ]);
  }

  Widget _iconeLivre(DetailleBookModel livre) {
    return Container(
      width: 120, height: 140, color: Colors.grey[200],
      child: Icon(
        livre.est_audio ? Icons.audiotrack : Icons.picture_as_pdf,
        size: 40, color: Colors.grey,
      ),
    );
  }

  // ── Ouvrir fichier local ──────────────────────────────────────────────
 /*
  Future<void> _ouvrirFichierLocal(BookViewModel vm, String id,bool pdf,bool audio) async {
    final String? chemin = await vm.getCheminFichierLocal(id,pdf,audio);
    if (!mounted) return;
    if (chemin == null) {
      _showSnackBar('Fichier introuvable. Retéléchargez-le.', Colors.red);
      return;
    }
    // Naviguer vers le bon lecteur
    final bool estAudio = chemin.endsWith('.mp3');
    Navigator.pushNamed(
      context,
      estAudio ? '/lecteur_audio' : '/lecteur_pdf',
      arguments: {'chemin': chemin, 'titre': vm.livreDetail?.bookTitle ?? ''},
    );
  }
*/

  Future<void> _ouvrirFichier( BuildContext context, BookViewModel vm, DetailleBookModel livre,bool pdf,bool audio) async
  {
    final String? chemin =
    await vm.getCheminFichierLocal(livre.id,pdf,audio);
    if (chemin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Fichier introuvable. Veuillez le retélécharger.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    // ← Navigation vers le lecteur PDF ou Audio
    if (livre.est_audio) {
      Navigator.pushNamed(context, '/lecteur_audio',
          arguments: {'chemin': chemin, 'titre': livre.titre});
    } else {
      Navigator.pushNamed(context, '/lecteur_pdf',
          arguments: {'chemin': chemin, 'titre': livre.titre});
    }
  }

  // ── Dialog suppression ────────────────────────────────────────────────
  Future<void> _confirmerSuppression(
      BuildContext context, BookViewModel vm, DetailleBookModel livre) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le téléchargement'),
        content: Text(
            'Supprimer "${livre.titre}" de vos téléchargements ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await vm.supprimerLivreLocal(
          livre, vm.numero);
    }
  }

  // ── Profil (lecture DB locale) ────────────────────────────────────────
  Widget _buildProfil() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DatabaseHelper.instance.getUser(),
      builder: (_, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        final String profile = data['profile']?.toString() ?? '';
        final String profileUrl = profile.isEmpty || profile == 'user.png'
            ? ''
            : 'https://eduniger.com/api/profiles/$profile';
        return Column(children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: profileUrl.isNotEmpty
                ? NetworkImage(profileUrl)
                : const AssetImage('assets/images/user.png')
            as ImageProvider,
          ),
          const SizedBox(height: 10),
          Text('${data['firstName'] ?? ''} ${data['name'] ?? ''}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          Text(data['email']?.toString() ?? '',
              style: const TextStyle(color: Colors.grey)),
        ]);
      },
    );
  }

  Widget _buildListTile(IconData icon, String titre, String count) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(titre),
      trailing: Text(count,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectionVide(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(children: [
        Icon(Icons.inbox_outlined, size: 50, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ]),
    );
  }
}
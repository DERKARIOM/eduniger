import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/modelBook.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../models/modelDetailBook.dart';
import '../../services/detailBook_api.dart';
import '../../services/detailBook_api.dart';
import '../../services/recomandation_api.dart'; // Pour le support du français

class Detailbook extends StatefulWidget {
  final String idBook;
  final String idUser;
  const Detailbook({
    super.key,
    required this.idBook,
    required this.idUser, });

  @override
  State<Detailbook> createState() => _DetailbookState();
}

class _DetailbookState extends State<Detailbook> {
  static const String baseUrl = 'https://eduniger.com/ressources/cover/';
  static const String baseUrlProfile = 'https://eduniger.com/ressources/profile/';
  bool onLike=false;
  String formaBook='';
  String forma='';
  BookDetailResponse book = BookDetailResponse();
  IconData icon=Icons.picture_as_pdf;
  // Fonction pour mettre à jour le texte du format selon l'icône sélectionnée
  void _updateFormatBook(IconData selectedIcon) {
    setState(() {
      icon = selectedIcon; // Met à jour l'icône affichée
      switch (selectedIcon) {
        case Icons.picture_as_pdf:
          formaBook = ' numérique';
          break;
        case Icons.audiotrack:
          formaBook = ' audio';
          break;
        case Icons.menu_book_sharp:
          formaBook = ' physique';
          break;
        case Icons.videocam:
          formaBook = ' vidéo';
          break;
        default:
          formaBook = ' numérique';
      }
    });
  }

  late Future<AuthResponse> _dataFuture;
  //selectionner format automatique
  void _autoSelectFormat() {
    // On ne change rien si un format est déjà défini (pour éviter d'écraser un choix utilisateur)
    if (formaBook.isNotEmpty) return;

    if (book.electronic != null && book.electronic!.isNotEmpty) {
      _updateFormatBook(Icons.picture_as_pdf);
    } else if (book.isPhysic == true) {
      _updateFormatBook(Icons.menu_book_sharp);
    } else if (book.isAudio == true) {
      _updateFormatBook(Icons.audiotrack);
    }
  }
  //late Future<Map<String, dynamic>> _dataFuture;
  void _loadData() {setState(() {
    _dataFuture = DetailbookApi.getBookDetail(
      id_user: widget.idUser,
      id_book: widget.idBook,
    ).timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        throw TimeoutException('Le chargement prend trop de temps.');
      },
    ); // Plus de cast (as ...) ici, car les types correspondent maintenant
  });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

      ),
      body: FutureBuilder<AuthResponse>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState();
          }
          // On récupère l'objet AuthResponse
          final response = snapshot.data!;

          if (response.status == 'success' && response.data != null) {
            // On extrait l'objet livre de la propriété 'data' de AuthResponse
            book = response.data!;
            // On utilise WidgetsBinding pour éviter l'erreur "setState() called during build"
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _autoSelectFormat();
            });

            return _buildSuccessState();
          } else {
            return _buildErrorState(response.message);
          }

        },




          ),
          );
  }
  _buildErrorState(String error) {
    return Center(
      child: Text('Erreur : $error'),
    );
  }

  _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.green,
        backgroundColor: Colors.white,
      ),
    );
  }
  _buildEmptyState() {
    return Center(
      child: Text('Aucun livre trouvé'),
    );
  }
  _buildSuccessState(){
    return
      SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            //SizedBox(height: 10,),
            _buildInfoBook(),
            SizedBox(height: 10,),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("L'auteur du livre "),
                  IconButton(onPressed:(){} ,
                      icon: Icon(Icons.change_history,color: Colors.green,size: 15,)),
                ]
            ),
            _buildInfoHoter(),
            SizedBox(height: 20,),
            /*
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Format ${formaBook}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),

                  IconButton(onPressed:(){

                  } ,
                      icon: Icon(Icons.menu_sharp,color: Colors.green,size: 15,)),
                ]
            ),
            */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                   "Format :${formaBook}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                ),

                // Conteneur des icônes de format disponibles
                Row(
                  children: [
                    // Format Numérique (PDF)
                    if (book.electronic != null && book.electronic!.isNotEmpty)
                      IconButton(
                        onPressed: () => _updateFormatBook(Icons.picture_as_pdf),
                        icon: Icon(
                          Icons.picture_as_pdf,
                          color: icon == Icons.picture_as_pdf ? Colors.orange : Colors.green,
                          size: 18,
                        ),
                      ),

                    // Format Physique
                    if (book.isPhysic == true)
                      IconButton(
                        onPressed: () => _updateFormatBook(Icons.menu_book_sharp),
                        icon: Icon(
                          Icons.menu_book_sharp,
                          color: icon == Icons.menu_book_sharp ? Colors.orange : Colors.green,
                          size: 18,
                        ),
                      ),

                    // Format Audio
                    if (book.isAudio == true)
                      IconButton(
                        onPressed: () => _updateFormatBook(Icons.audiotrack),
                        icon: Icon(
                          Icons.audiotrack,
                          color: icon == Icons.audiotrack ? Colors.orange : Colors.green,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10,),
            _buildTelechargeBook(),
            SizedBox(height: 20,),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Apopos du livre "),
                  IconButton(onPressed:(){} ,
                      icon: Icon(Icons.change_history,color: Colors.green,size: 15,)),
                ]
            ),
            _buildApropoBook(),
            SizedBox(height: 7,),
            _buildCommantaireBook(),
          ],
        ),
      ),
    );

  }
  //info du livre
  Widget _buildInfoBook(){
    return
    Container(
      height: 200,
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child:  ClipRRect(

              borderRadius: BorderRadius.circular(10),
              child: Image.network( '$baseUrl${book.bookBlanket!}',
                fit: BoxFit.cover,
                width: 100,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),


            /*CustomImageView(
                      imagePath: '$baseUrl${couverture[index].blanket!}',
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      errorWidget:
                         Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 40),

                         )
                    )*/


          ).animate(delay: (2 * 100).ms).fadeIn(),
          SizedBox(width: 20,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                Text('${book.bookTitle}',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 14,),),
                SizedBox(height: 10,),
                Text('De: ${book.firstName ?? ""} ${book.name ?? ""}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Colors.grey),),
                SizedBox(height: 10,),
                Text('Catégorie: ${book.categoryTitle}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Colors.grey),),

                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(onPressed:(){
                      setState(() {
                        onLike=!onLike;
                      });
                    } ,icon:  onLike ? Icon(Icons.thumb_up,color: Colors.green,size: 20,)  : Icon(Icons.thumb_up_off_alt,color: Colors.green,size: 20,),),
                    Text(book.numberLike.toString() ?? "0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                    const SizedBox(width: 4),
                      book.isPhysic ==true ?Icon(Icons.menu_book_sharp,color: Colors.green,size: 15,):SizedBox(),
                    const SizedBox(width: 4),
                       book.electronic !='' ?Icon(Icons.picture_as_pdf,color: Colors.green,size: 15,):SizedBox(),
                    const SizedBox(width: 4),
                      book.isAudio ==true ?Icon(Icons.audiotrack,color: Colors.green,size: 15,):SizedBox(),
                    const SizedBox(width: 4),

                    Icon(Icons.notifications_none_sharp,color: Colors.green,size: 15,),
                    Text("0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),

                    const SizedBox(width: 10),
                    Icon(Icons.visibility_sharp,color: Colors.green,size: 15,),
                    Text(book.numberView.toString()??"0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),)


                  ],
                ),


              ],
            ),
          ),

        ],
      ),
    );


  }
  //info auteur
  Widget _buildInfoHoter() {
    return Container(
      // Retrait de la hauteur fixe pour laisser le contenu respirer
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        leading: SizedBox(
          width: 60,
          height: 60,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            backgroundImage: (book.profile != null && book.profile!.isNotEmpty)
                ? NetworkImage('$baseUrlProfile${book.profile}')
                : null,
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint("Erreur de chargement du profil: $exception");
            },
            child: (book.profile == null || book.profile!.isEmpty)
                ? const Icon(Icons.person, color: Colors.grey, size: 30)
                : null,
          ),
        ),
        title: Text(
          book.profession ?? 'Profession non définie',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Utilisation d'une syntaxe conditionnelle plus robuste (vérifie null ET vide)
              if (book.email != null && book.email!.isNotEmpty) ...[
                _buildContactRow(Icons.mail, book.email!, label: "Mail: "),
                const SizedBox(height: 4),
              ],

              if (book.call != null && book.call!.isNotEmpty) ...[
                _buildContactRow(Icons.phone, book.call!, label: "Téléphone: "),
                const SizedBox(height: 4),
              ],

              if (book.whatsapp != null && book.whatsapp!.isNotEmpty) ...[
                _buildContactRow(Icons.chat, book.whatsapp!, label: "WhatsApp: "),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }

// Méthode utilitaire pour éviter la répétition de code
  Widget _buildContactRow(IconData icon, String text, {String label = ""}) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            "$label$text",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
  //gestion du telechargement
  Widget _buildTelechargeBook(){
    return Container();
  }
  //appropos du livre
  Widget _buildApropoBook() {
    return Container(
      width: double.infinity, // S'assure que le container prend toute la largeur
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        // Note : Assurez-vous d'utiliser le bon champ (ex: resume ou description)
        // si nameStruct ne contient que le nom de l'auteur.
        '${book.description}',
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5, // Augmente l'interligne pour une meilleure lisibilité
          color: Colors.black87,
        ),
        // softWrap est à true par défaut, ce qui permet le passage à la ligne automatique
        softWrap: true,
      ),
    );
  }
  //commentaire du livre
  Widget _buildCommantaireBook(){
    return Container();
  }
}

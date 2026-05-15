import 'package:eduniger/features/livres/view_models/book_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../appstate.dart';
import '../view_model/structure_view_model.dart';

class Livre_Stricture extends StatefulWidget {
  const Livre_Stricture({super.key});

  @override
  State<Livre_Stricture> createState() => _LivreState();
}

class _LivreState extends State<Livre_Stricture> {
  AppState get appState => context.watch<AppState>();
late int id;
  bool _isInitialized = false;

  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        id = args['id'];
        //numero = args['numero'].toString();
      }
      else{
        debugPrint("Erreur de chargement");
      }
      _isInitialized = true;
      Future.microtask(() {
        if (mounted) {
          final vm = context.read<StructureViewModel>();
          vm.chargerLivreStructure(id ?? 0);
        }
        /*
        if (mounted) {
          context.read<BookViewModel>().chargerDetail(numero, idBook);
        }
        */
      });
    }
  }

  @override
  void initState() {
    super.initState();

  }


  //List<Book> couverture = [];
  @override
  Widget build(BuildContext context) {
    return
      Consumer<StructureViewModel>(
        builder: (context, vm, _) {

           return  _buildBody(vm);

        }


      );
  }
  Widget _buildBody(StructureViewModel vm) {
    //print('$_baseUrlCover''logos/''logo.png');
    if (vm.isLoading && vm.book_structure.isEmpty)               return _buildLoadingState();
    if (vm.errorMessage.isNotEmpty && vm.book_structure.isEmpty) return _buildErrorState(vm);
    return _buildContentState(vm);
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  Widget _buildContentState(StructureViewModel vm) {
    return
      Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.multiline,
                maxLines: null, // Permet au champ de s'agrandir si le texte est long
                decoration: InputDecoration(
                  hintText: 'recherche...', // Utiliser hintText (String) et non hint (Widget)
                  border: InputBorder.none,
                  suffixIcon: const Icon(Icons.search),
                  suffixIconColor: Colors.grey,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body:  vm.book_structure.isEmpty
              ? const Center(child: Text("Aucun livre trouvé"))
              :
          ListView.builder(
              padding: const EdgeInsets.only(
                  left: 30, top: 20, right: 5),
              itemCount: vm.book_structure.length,
              itemBuilder: (context, index) {
                final book = vm.book_structure[index];

                return InkWell(
                  onTap: () => Navigator.pushNamed(
                    context, '/detail_livre',
                    arguments: {
                      'idBook': book.idBook,
                      'numero': context.read<AppState>().numeroUtilisateur,
                    },
                  ),
                  child: Padding(
                    // Ajoute un peu d'espace entre chaque élément de la liste
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Aligne les éléments en haut
                      children: [
                        // --- 1. L'image de couverture ---
                        Container(
                          width: 60,
                          height: 95,
                          // La hauteur sera maintenant respectée !
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              "${AppState.baseUrlCover}${book.dStructures}/blankets/${book.blanket}",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),
                        // Espace horizontal entre l'image et le texte

                        // --- 2. La colonne pour le titre et le sous-titre ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // Aligne le texte à gauche
                            children: [
                              const SizedBox(height: 15),
                              // Petit espace pour centrer verticalement
                              Text(
                                book.bookTitle ?? "",
                                style: const TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.bold),
                                // Permet au texte de passer à la ligne s'il est trop long
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Espace entre le titre et le sous-titre
                              Text(
                                "${book.nameStruct} : ${book
                                    .categoryTitle}",
                                style: const TextStyle(fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              // Espace entre le sous-titre et le bouton
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                children: [
                                  book.isPhysic == true
                                      ? Icon(Icons.menu_book_sharp,
                                    color: Colors.green, size: 15,)
                                      : SizedBox(),
                                  const SizedBox(width: 8),
                                  book.electronic !='null'
                                      ? Icon(Icons.picture_as_pdf,
                                    color: Colors.green, size: 15,)
                                      : SizedBox(),
                                  const SizedBox(width: 8),
                                  book.isAudio == true ? Icon(
                                    Icons.audiotrack, color: Colors.green,
                                    size: 15,) : SizedBox(),
                                  const SizedBox(width: 8),
                                  Icon(Icons.thumb_up_off_alt,
                                    color: Colors.green, size: 15,),
                                  Text(book.numberLike.toString() ?? "0",
                                    style: TextStyle(fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),),
                                  const SizedBox(width: 15),
                                  Icon(Icons.visibility_sharp,
                                    color: Colors.green, size: 15,),
                                  Text(book.numberView.toString() ?? "0",
                                    style: TextStyle(fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),)


                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

          )
      );

  }
  Widget _buildErrorState(StructureViewModel vm) {
    final String error = vm.errorMessage;

    IconData errorIcon;
    String   errorTitle;
    String   errorMessage;
    Color    errorColor;

    if (error == 'pasDeConnexion' || error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      errorIcon    = Icons.wifi_off;
      errorTitle   = 'Pas de connexion';
      errorMessage = 'Vérifiez votre connexion Internet et réessayez.';
      errorColor   = Colors.orange;
    } else if (error == 'timeout' || error.contains('trop de temps')) {
      errorIcon    = Icons.access_time;
      errorTitle   = 'Délai dépassé';
      errorMessage = 'Le serveur met trop de temps à répondre.';
      errorColor   = Colors.amber;
    } else if (error == '401') {
      errorIcon    = Icons.lock;
      errorTitle   = 'Non autorisé';
      errorMessage = 'Votre session a expiré. Reconnectez-vous.';
      errorColor   = Colors.red;
    } else if (error == '404') {
      errorIcon    = Icons.search_off;
      errorTitle   = 'Ressource introuvable';
      errorMessage = 'Les données demandées n\'existent pas.';
      errorColor   = Colors.blue;
    } else if (error == '500') {
      errorIcon    = Icons.error;
      errorTitle   = 'Erreur serveur';
      errorMessage = 'Le serveur rencontre un problème.';
      errorColor   = Colors.red;
    } else {
      errorIcon    = Icons.warning;
      errorTitle   = 'Erreur';
      //errorMessage = error;
      errorMessage = 'Une erreur s \'est produite.';

      errorColor   = Colors.grey;
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(errorIcon, size: 80, color: errorColor)
                  .animate(onPlay: (c) => c.repeat())
                  .shake(duration: 500.ms, hz: 2),
              const SizedBox(height: 24),
              Text(errorTitle,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: errorColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(errorMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    // ← délégué au ViewModel
                    onPressed:(){ vm.chargerLivreStructure(id?? 0);},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/bibliotheque'),
                    child: const Text('Bibliothèque locale',
                        style: TextStyle(color: Colors.grey)),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

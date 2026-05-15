import 'package:eduniger/features/structures/model/structure_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../appstate.dart';
import '../../livres/models/book_model.dart';
import '../view_model/structure_view_model.dart';
class DetailleStructure extends StatefulWidget {
   DetailleStructure({super.key,});

  @override
  State<DetailleStructure> createState() => _DetailleStructureState();
}

class _DetailleStructureState extends State<DetailleStructure> {
  late Structure idStruct;
  bool _isInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        idStruct = args['id'];
        //numero = args['numero'].toString();
      }
      else{
        debugPrint("Erreur de chargement");
      }
      _isInitialized = true;
      Future.microtask(() {
        if (mounted) {
          final vm = context.read<StructureViewModel>();
          vm.chargerLivreStructure(idStruct.id ?? 0);
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
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StructureViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text('Detaille'),
          ),
          body:  SingleChildScrollView(
            child: _buildBody(vm),
          ),

          bottomNavigationBar: Container(
            // On utilise MediaQuery pour s'assurer que le clavier ne cache pas la barre
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea( // Gère les zones sécurisées (encoches du bas sur iPhone/Android)
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                // On retire la hauteur fixe "height: 60" pour laisser le TextField s'adapter
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null, // Permet au champ de s'agrandir si le texte est long
                          decoration: InputDecoration(
                            hintText: 'Votre commentaire...', // Utiliser hintText (String) et non hint (Widget)
                            border: InputBorder.none,
                            icon: Icon(Icons.message, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 22,
                      child: IconButton(
                        onPressed: () {
                          // Action d'envoi
                        },
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

        ) ;
      },
    );
  }
  Widget _buildBody(StructureViewModel vm) {
    if(vm.isLoading && vm.book_structure.isEmpty)               return _buildLoadingState();
    if (vm.errorMessage.isNotEmpty && vm.book_structure.isEmpty) return _buildErrorState(vm);
    return _buildContentState(vm);

  }
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
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

    return
       Center(
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
                    icon: const Icon(Icons.refresh),
                    onPressed:(){vm.chargerLivreStructure(idStruct.id ??0 );},
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

    );
  }
  Widget _buildContentState(StructureViewModel vm) {
    return
      Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
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
                  "${AppState.baseUrlCover}${idStruct.id}/banners/${idStruct.banner}",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35, // Augmenté pour un meilleur aspect
                  backgroundImage:
                  (idStruct.logo != null && idStruct.logo!.isNotEmpty)
                      ? NetworkImage(
                    "${AppState.baseUrlCover}${idStruct.id}/logos/${idStruct.logo}",
                  ): null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(idStruct.name??'',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    Text(idStruct.author??'',style: TextStyle(fontSize: 12),),
                    Text('${idStruct.adhererNumber} adhérents ${idStruct.bookNumber} livres',style: TextStyle(fontSize: 14),),
                  ],
                )

              ],
            ),
            SizedBox(height: 10,),
            Container(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed:(){},
                label: Text('S\'adhérer',style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                icon: Icon(Icons.notifications, size: 14,),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),

              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Livres',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context, '/livre_structure',
                    arguments: {
                      'id': idStruct.id,
                      //'numero': context.read<AppState>().numeroUtilisateur,
                    },
                  ),
                  child: Text('Voir plus',style: TextStyle(fontSize: 13),),
                ),

              ],
            ),
            Container(
              height: 160,
              child:
              vm.book_structure.isEmpty
                  ? Center(child: Text('Aucun livre recommandé pour le moment'))
                  : SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.book_structure.length.clamp(0, 6),
                  itemBuilder: (_, index) {
                    final Book book = vm.book_structure[index];
                    return InkWell(

                      onTap: () => Navigator.pushNamed(
                        context, '/detail_livre',
                        arguments: {
                          'idBook': book.idBook,
                          'numero': context.read<AppState>().numeroUtilisateur,
                        },
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            "${AppState.baseUrlCover}${book.dStructures}/blankets/${book.blanket}",
                            fit: BoxFit.cover,
                            width: 100, height: 150,
                            errorBuilder: (_, __, ___){
                              return
                                Container(
                              width: 100, height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 40),
                            );},
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 100, height: 150,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ).animate(delay: (index * 100).ms).fadeIn(),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text(idStruct.description??'',maxLines: 7,style: TextStyle(
              fontSize: 14,

            ),),
            Divider(
              color: Colors.grey,
              thickness: 1,
            ),


          ],
        ),
      );

  }

}

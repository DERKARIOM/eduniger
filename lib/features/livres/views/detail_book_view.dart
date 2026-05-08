import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../appstate.dart';
import '../dto/detaille_book_dto.dart';
import '../view_models/book_view_model.dart';
/*
class DetailBookView extends StatefulWidget {
  const DetailBookView({super.key});

  @override
  State<DetailBookView> createState() => _DetailBookViewState();
}

class _DetailBookViewState extends State<DetailBookView> {
  //AppState get appState => context.watch<AppState>();
  bool onLike=false;
  bool vue=false;
  late String idBook;
  late String numero;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Map) {
        idBook = args['idBook'].toString();
        numero = args['numero'].toString();
      }

      _isInitialized = true;

      Future.microtask(() {
        if (mounted) {
          context.read<BookViewModel>().chargerDetail(numero ,idBook);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              // On affiche le titre seulement si les données sont là
              title: Text("Détails du livre"),
              elevation: 0,
            ),
            body: _buildBody(vm),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 8, // Ajuste pour le clavier
                left: 8,
                right: 8,
                top: 8,
              ),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: TextField(
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ecrire votre commentaire', // Utiliser hintText et une String
                  ),
                ),
              ),
            ),

        );
      }
        );
      }



  Widget _buildBody(BookViewModel vm) {
    if (vm.isLoading && vm.livreDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage.isNotEmpty) {
      return _buildErrorState(vm);
    }
    // 3. SECURITÉ : Si le livre est toujours null (et qu'on n'est pas en erreur)
    if (vm.livreDetail == null) {
      //return const Center(child: Text("Chargement des détails..."));
      return const Center(child: CircularProgressIndicator());
    }

    return _buildContentState(vm);
  }

  // Cette méthode ne retourne PLUS un Scaffold, mais juste le contenu
  Widget _buildContentState(BookViewModel vm) {
    final detail = vm.livreDetail;
    // Vérification de sécurité au cas où
    if (detail == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child:  ClipRRect(

              borderRadius: BorderRadius.circular(10),
              child: Image.network("${AppState.baseUrlCover}${detail.idStructure}/blankets/${detail.bookBlanket}",

                fit: BoxFit.cover,
                width: 150,
                height: 190,
              )
          )
            ),
                SizedBox(height: 10,),
                Text('${detail.bookTitle}',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('De: ${detail.firstName ?? ""} ${detail.name ?? ""}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Colors.grey),),
                    Text('Catégorie: ${detail.categoryTitle}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Colors.grey),),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed:(){
                      setState(() {

                      });
                    } ,icon:  onLike ? Icon(Icons.thumb_up,color: Colors.green,size: 24,)  : Icon(Icons.thumb_up_off_alt,color: Colors.green,size: 20,),
                    ),
                    Text(detail.numberLike.toString() ?? "0",style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),),
                    const SizedBox(width: 20),
                    IconButton(onPressed: (){},
                        icon: vue? Icon(Icons.notifications,color: Colors.green,size: 24,):Icon(Icons.notifications_none,color: Colors.green,size: 20,)
                    ),
                    Text("0",style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),),

                    const SizedBox(width: 20),
                    Icon(Icons.visibility_sharp,color: Colors.green,size: 24,),
                    SizedBox(width: 10,),
                    Text(detail.numberView.toString()??"0",style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),)
                  ],
                ),
                detail.electronic !='' ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.picture_as_pdf,color: Colors.green,size: 35,),
                        SizedBox(width: 10,),
                        Text("Format Electronique disponible :  Taille :${detail.size} M  ${detail.nbrPage} Pages",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                      ],
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed:(){} , child: Container(
                      alignment: Alignment.center,
                        width: 200,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text('Telecharger'),
                    )),
                  ],
                ):SizedBox(),
                detail.isAudio ==1 ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.audiotrack_sharp,color: Colors.green,size: 35,),
                        SizedBox(width: 10,),
                        Text("Format Audio disponible :  Taille :${detail.size} M",style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),),
                      ],
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed:(){} , child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('Telecharger'),
                    )),
                  ],
                ):SizedBox(),
                detail.isPhysic ==1 ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.menu_book_sharp,color: Colors.green,size: 35,),
                        SizedBox(width: 10,),
                        Text("Format Physique disponible :  Taille :${detail.size} M",style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),),
                      ],
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed:(){} , child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('Réserver'),
                    )),
                  ],
                ):SizedBox(),
                SizedBox(height: 10,),
                Text("Description",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                SizedBox(height: 4,),
                Text("${detail.description}",style: TextStyle(fontSize: 12, color: Colors.grey),),



              ],
            )
      )

    );
  }
  /*
                Container(
                  width: double.infinity,
                  height:700,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        SizedBox(height: 10,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child:  ClipRRect(

                            borderRadius: BorderRadius.circular(10),
                            child: Image.network("${AppState.baseUrlCover}${detail.idStructure}/blankets/${detail.bookBlanket}",

                              fit: BoxFit.cover,
                              width: 150,
                              height: 190,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 250,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 40),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 140,
                                  height: 100,
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

                        ).animate(delay: (2 * 100).ms).fadeIn(),


                        SizedBox(height: 10,),
                        Text('${detail.bookTitle}',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                        SizedBox(height: 4,),
                Text('De: ${detail.firstName ?? ""} ${detail.name ?? ""}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Colors.grey),),
                SizedBox(height: 10,),
                Text('Catégorie: ${detail.categoryTitle}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 10,color: Colors.grey),),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(onPressed:(){
                      setState(() {
                        onLike=!onLike;
                      });
                    } ,icon:  onLike ? Icon(Icons.thumb_up,color: Colors.green,size: 20,)  : Icon(Icons.thumb_up_off_alt,color: Colors.green,size: 20,),),
                    Text(detail.numberLike.toString() ?? "0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                    const SizedBox(width: 4),
                    IconButton(onPressed: (){},
                        icon: vue? Icon(Icons.notifications,color: Colors.green,size: 20,):Icon(Icons.notifications_none,color: Colors.green,size: 20,) ),
                    Text("0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),

                    const SizedBox(width: 10),
                    Icon(Icons.visibility_sharp,color: Colors.green,size: 15,),
                    Text(detail.numberView.toString()??"0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),)


                  ],
                ),
                const SizedBox(height: 4),
                 detail.electronic !='' ? Column(
                   children: [
                     Text("Format Electronique disponible :"),
                     Container(
                       height: 40,
                       margin: const EdgeInsets.symmetric(horizontal: 4),
                       decoration: BoxDecoration(
                         borderRadius: const BorderRadius.all(Radius.circular(10)),
                         border: Border.all(color: Colors.grey, width: 1),
                       ),
                       child:Row(
                         mainAxisAlignment: MainAxisAlignment.start,
                         children: [
                          Icon(Icons.picture_as_pdf,color: Colors.green,size: 25,),
                           Container(
                             width: 90,
                             height: 20,
                             margin: const EdgeInsets.symmetric(horizontal: 4),
                           decoration: BoxDecoration(
                             borderRadius: const BorderRadius.all(Radius.circular(10)),
                             border: Border.all(color: Colors.grey, width: 1),
                           ),
                             child:Text("Téléchargement",style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.grey),),
                           ),
                           const SizedBox(width: 0),
                           Text(" Taille :${detail.size}",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                           const SizedBox(width: 4),
                           Text(" Nombre de page :${detail.nbrPage}",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                         ],
                       ) ,

                     )
                   ]
                 ):SizedBox(),
                const SizedBox(height: 4),
                detail.isAudio ==1 ? Column(
                    children: [
                      Text("Format Audio disponible :"),
                      Container(
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.audiotrack_sharp,color: Colors.green,size: 15,),
                            Container(
                              width: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              child:Text("Téléchargement",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                            ),
                            const SizedBox(width: 10),
                            Text(" Taille :${detail.size}"),
                             ],
                        ) ,

                      )
                    ]
                ):SizedBox(),
                const SizedBox(height: 4),
                detail.isPhysic ==1 ?  Column(
                    children: [
                      Text("Format physique disponible :"),
                      Container(
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.menu_book_sharp,color: Colors.green,size: 15,),
                            Container(
                              width: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              child:Text("Reserver",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),
                            ),
                            const SizedBox(width: 10),
                            ProgressIndicatorTheme(data: ProgressIndicatorThemeData(color: Colors.green),
                                child:CircularProgressIndicator(
                                  value: 0.5,
                                  strokeWidth: 2,
                                )),
                            ],
                        ) ,

                      )
                    ]
                ):SizedBox(),



                      ]

                  ),
                ),


                SizedBox(height: 10,),
                Text("Description",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                SizedBox(height: 4,),
                Text("${detail.description}",style: TextStyle(fontSize: 12, color: Colors.grey),),
                */
  Widget _buildErrorState(BookViewModel vm) {
    final String error = vm.errorMessage;
    IconData errorIcon = Icons.warning;
    String errorTitle = 'Erreur';
    Color errorColor = Colors.grey;

    if (error == 'pasDeConnexion') {
      errorIcon = Icons.wifi_off;
      errorTitle = 'Pas de connexion';
      errorColor = Colors.orange;
    } else if (error == '404') {
      errorIcon = Icons.search_off;
      errorTitle = 'Livre introuvable';
      errorColor = Colors.blue;
    }

    return Center(
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: errorColor)),
            const SizedBox(height: 12),
            const Text('Une erreur s\'est produite lors du chargement.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<BookViewModel>().chargerDetail(numero,idBook),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

}

*/
class DetailBookView extends StatefulWidget {
  const DetailBookView({Key? key}) : super(key: key);
  @override
  State<DetailBookView> createState() => _DetailBookViewState();
}

class _DetailBookViewState extends State<DetailBookView> {
  late String idBook;
  late String numero;
  bool _isInitialized = false;

  final TextEditingController _commentController = TextEditingController();
  final String duree = '3';
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        idBook = args['idBook'].toString();
        numero = args['numero'].toString();
      }
      _isInitialized = true;
      Future.microtask(() {
        if (mounted) {
          final vm = context.read<BookViewModel>();
          vm.chargerDetail(numero, idBook);
          // ← Vérifier état local dès l'ouverture
          vm.verifierEtatFichier(idBook);
        }
        /*
        if (mounted) {
          context.read<BookViewModel>().chargerDetail(numero, idBook);
        }
        */
      });
    }
  }

  // ── Snackbar centralisé ─────────────────────────────────────────────
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

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

  // ── Traduction des actionMessage ────────────────────────────────────
  void _handleActionMessage(BookViewModel vm) {
    if (vm.actionMessage.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (vm.actionMessage) {
        case 'telecharge_ok':
          _showSnackBar('✅ Téléchargement terminé !', Colors.green);
          break;
        case 'deja_telecharge':
          _showSnackBar('📚 Déjà téléchargé', Colors.blue);
          break;
        case 'reserve_ok':
          _showSnackBar('✅ Réservation confirmée !', Colors.green);
          break;
        case 'deja_reserve':
          _showSnackBar('📋 Déjà réservé', Colors.blue);
          break;
        case 'like_ok':
          _showSnackBar('👍 J\'aime enregistré', Colors.green);
          break;
        case 'comment_ok':
          _showSnackBar('💬 Commentaire envoyé', Colors.green);
          _commentController.clear();
          break;
        default:
          _showSnackBar(vm.actionMessage, Colors.orange);
      }
      vm.clearActionMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookViewModel>(
      builder: (context, vm, _) {
        _handleActionMessage(vm);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(vm.livreDetail?.bookTitle ?? 'Détail du livre'),
            elevation: 0,
          ),
          body: _buildBody(vm),
          // ── Zone de commentaire ──────────────────────────────────
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              left: 8, right: 8, top: 8,
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Écrire un commentaire...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    vm.commenterLivre(idBook, _commentController.text);
                  }
                },
                icon: const Icon(Icons.send, color: Colors.green),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ── Body ────────────────────────────────────────────────────────────
  Widget _buildBody(BookViewModel vm) {
    if (vm.isLoadingDetail) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }
    if (vm.errorMessage.isNotEmpty) return _buildErrorState(vm);
    if (vm.livreDetail == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }
    return _buildContenu(vm);
  }

  // ── Contenu principal ───────────────────────────────────────────────
  Widget _buildContenu(BookViewModel vm) {
    final BookDetailDto detail = vm.livreDetail!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(children: [

        // ── Couverture ──────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            '${AppState.baseUrlCover}${detail.idStructure}/blankets/${detail.bookBlanket}',
            width: 150, height: 190, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 150, height: 190, color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 150, height: 190, color: Colors.grey[300],
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.green)),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Titre + auteur + catégorie ──────────────────────────────
        Text(detail.bookTitle ?? '',
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('${detail.firstName ?? ''} ${detail.name ?? ''}',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text('Catégorie : ${detail.categoryTitle ?? ''}',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),

        const SizedBox(height: 12),

        // ── Statistiques : likes / abonnés / vues ──────────────────
        _buildStats(vm, detail),

        const Divider(height: 24),

        // ── Formats disponibles ─────────────────────────────────────
        if (detail.electronic !='' && detail.electronic !=null)
          _buildFormatPdf(vm, detail),
        if (detail.isAudio == true)
          _buildFormatAudio(vm, detail),
        if (detail.isPhysic == true)
          _buildFormatPhysique(vm, detail),

        const Divider(height: 24),

        // ── Description ─────────────────────────────────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(detail.description ?? '',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),

        const SizedBox(height: 80), // espace pour le bottomNavigationBar
      ]),
    );
  }

  // ── Statistiques ────────────────────────────────────────────────────
  Widget _buildStats(BookViewModel vm, BookDetailDto detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Like
        InkWell(
          onTap: () => vm.likerLivre(idBook),
          child: Row(children: [
            vm.liker?  Icon(Icons.thumb_up_outlined, color: Colors.green, size: 22) : Icon(Icons.thumb_up_outlined, color: Colors.grey, size: 22),
            const SizedBox(width: 4),
            Text('${detail.numberLike ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
        // Dislike
        InkWell(
          onTap: () => vm.dislikerLivre(idBook),
          child: Row(children: [
           vm.noliker ? Icon(Icons.thumb_down_outlined, color: Colors.deepOrange, size: 22): Icon(Icons.thumb_down_outlined, color: Colors.grey, size: 22),
            const SizedBox(width: 4),
            Text('${detail.numberNoLike ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
        // Abonnés
        Row(children: [
         vm.subscribe ? Icon(Icons.notifications_active_outlined, color: Colors.green, size: 22) :  Icon(Icons.notifications_outlined, color: Colors.grey, size: 22),
          const SizedBox(width: 4),
          Text('${detail.numberSubscribe ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        // Vues
        Row(children: [
          const Icon(Icons.visibility, color: Colors.green, size: 22),
          const SizedBox(width: 4),
          Text('${detail.numberView ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ],
    );
  }
  // ══════════════════════════════════════════════════════════════════════
// BOUTON QUI SE TRANSFORME EN BARRE DE PROGRESSION
// ══════════════════════════════════════════════════════════════════════
  Widget _buildFormatPdf(BookViewModel vm, BookDetailDto detail) {
    final String idBook      = detail.idBook ?? '';
    final bool   enCours     = vm.enCoursParLivre['${idBook}_pdf'] ?? false;
    final bool   deja        = vm.dejaTelechage_pdf['${idBook}_pdf'] ?? false;
    final double progress    = vm.progressParLivre['${idBook}_pdf'] ?? 0.0;

    return _buildFormatCard(
      icon   : Icons.picture_as_pdf,
      couleur: Colors.brown,
      titre  : 'Format Électronique',
      infos  : 'Taille : ${detail.size ?? '?'} Mo',
      bouton : _boutonTelechargement(
        vm       : vm,
        detail   : detail,
        idBook   : idBook,
        enCours  : enCours,
        deja     : deja,
        progress : progress,
        couleur  : Colors.green,
        icone    : Icons.picture_as_pdf,
        type_pdf : true,
        type_audio : false,
      ),
    );
  }

  Widget _buildFormatAudio(BookViewModel vm, BookDetailDto detail) {
    final String idBook   = detail.idBook ?? '';
    final bool   enCours  = vm.enCoursParLivre['${idBook}_audio'] ?? false;
    final bool   deja     = vm.dejaTelechage_audio['${idBook}_audio'] ?? false;
    final double progress = vm.progressParLivre['${idBook}_audio'] ?? 0.0;

    return _buildFormatCard(
      icon   : Icons.audiotrack,
      couleur: Colors.blue,
      titre  : 'Format Audio (MP3)',
      infos  : 'Taille : ${detail.size ?? '?'} Mo',
      bouton : _boutonTelechargement(
        vm       : vm,
        detail   : detail,
        idBook   : idBook,
        enCours  : enCours,
        deja     : deja,
        progress : progress,
        couleur  : Colors.blue,
        icone    : Icons.audiotrack,
        type_pdf : false,
        type_audio: true,
      ),
    );
  }

// ── Bouton unifié : 3 états (télécharger / progression / ouvrir) ───────
  Widget _boutonTelechargement({
    required BookViewModel vm,
    required BookDetailDto detail,
    required String  idBook,
    required bool    enCours,
    required bool    deja,
    required double  progress,
    required Color   couleur,
    required IconData icone,
    required bool  type_pdf,
    required bool type_audio,
  }) {
    // ── ÉTAT 3 : Déjà téléchargé → bouton Ouvrir ──────────────────────
    if (deja && !enCours) {
      return SizedBox(
        height: 44, width: 130,
        child: ElevatedButton.icon(
          onPressed: () => _ouvrirFichierLocal(vm, idBook,type_pdf,type_audio),
          icon : Icon(icone, size: 14),
          label: const Text('Ouvrir', style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: couleur,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );
    }

    // ── ÉTAT 2 : En cours → barre de progression même forme que bouton ─
    if (enCours) {
      return SizedBox(
        height: 36, width: 130,
        child: _BarreProgressionBouton(
          progress: progress,
          couleur : couleur,
        ),
      );
    }

    // ── ÉTAT 1 : Pas encore téléchargé → bouton Télécharger ───────────
    return SizedBox(
      height: 40, width: 130,
      child: ElevatedButton.icon(
        onPressed: () => vm.telechargerLivre(detail,type_pdf,type_audio),
        icon : const Icon(Icons.download, size: 14),
        label: const Text('Télécharger', style: TextStyle(fontSize: 10)),
        style: ElevatedButton.styleFrom(
          backgroundColor: couleur,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

// ══════════════════════════════════════════════════════════════════════
// FORMAT PHYSIQUE — avec jours restants
// ══════════════════════════════════════════════════════════════════════
  Widget _buildFormatPhysique(BookViewModel vm, BookDetailDto detail) {
    final String idBook      = detail.idBook ?? '';
    final bool   enCours     = vm.reserveParLivre[idBook] ?? false;
    final bool   disponible  = (detail.available ?? 0) > 0;
    final bool   dejaReserve =
    vm.statutReservation.containsKey(idBook);
    final int    jours       = vm.joursRestants(idBook);
    final double progRes     = vm.progressionReservation(idBook);

    return _buildFormatCard(
      icon   : Icons.menu_book,
      couleur: Colors.orange,
      titre  : 'Format Physique',
      infos  : disponible
          ? '${detail.available} exemplaire(s) disponible(s)'
          : 'Stock indisponible',
      // Widget réservation en dessous du bouton
      extra  : dejaReserve
          ? _barreReservation(jours: jours, progress: progRes)
          : null,
      bouton : _boutonReservation(
        vm         : vm,
        idBook     : idBook,
        enCours    : enCours,
        disponible : disponible,
        dejaReserve: dejaReserve,
      ),
    );
  }

  Widget _boutonReservation({
    required BookViewModel vm,
    required String idBook,
    required bool   enCours,
    required bool   disponible,
    required bool   dejaReserve,
  }) {
    // Déjà réservé → label avec jours restants
    if (dejaReserve) {
      final int jours = vm.joursRestants(idBook);
      return SizedBox(
        height: 36, width: 130,
        child: ElevatedButton.icon(
          onPressed: null, // désactivé
          icon : const Icon(Icons.check_circle, size: 16),
          label: Text(
            jours > 0 ? '$jours j restants' : 'Expiré',
            style: const TextStyle(fontSize: 11),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: jours > 0 ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );
    }

    // En cours de réservation → barre de progression
    if (enCours) {
      return SizedBox(
        height: 36, width: 130,
        child: _BarreProgressionBouton(
          progress: -1, // -1 = indéterminé
          couleur : Colors.orange,
          label   : 'Réservation...',
        ),
      );
    }

    // Bouton Réserver
    return SizedBox(
      height: 40, width: 130,
      child: ElevatedButton.icon(
        onPressed: disponible
            ? () => _confirmerReservation(
            context.read<BookViewModel>(), idBook)
            : null,
        icon : const Icon(Icons.bookmark_add, size: 16),
        label: const Text('Réserver', style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: disponible ? Colors.orange : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

// ── Barre de jours restants pour réservation ──────────────────────────
  Widget _barreReservation({
    required int    jours,
    required double progress,
  }) {
    final Color couleur = jours > 7
        ? Colors.green
        : jours > 3
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            jours > 0 ? '⏳ $jours jour(s) restant(s)' : '⚠️ Expiré',
            style: TextStyle(
              fontSize   : 11,
              color      : couleur,
              fontWeight : FontWeight.bold,
            ),
          ),
          Text(
            'Date retour : ${_formatDate(DateTime.now().add(Duration(days: jours)))}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value          : progress,
            backgroundColor: Colors.grey[200],
            valueColor     : AlwaysStoppedAnimation<Color>(couleur),
            minHeight      : 6,
          ),
        ),
      ]),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

// ── Carte format réutilisable (avec slot extra optionnel) ──────────────
  Widget _buildFormatCard({
    required IconData icon,
    required Color    couleur,
    required String   titre,
    required String   infos,
    required Widget   bouton,
    Widget?           extra,
  }) {
    return Container(
      margin  : const EdgeInsets.symmetric(vertical: 8),
      padding : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color        : couleur.withOpacity(0.05),
        borderRadius : BorderRadius.circular(12),
        border       : Border.all(color: couleur.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: couleur, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold,
                      color: couleur)),
              Text(infos,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          )),
          bouton,
        ]),
        if (extra != null) extra,
      ]),
    );
  }







// ── Dialog confirmation réservation ──────────────────────────────────
  Future<void> _confirmerReservation(BookViewModel vm, String idBook) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la réservation'),
        content: const Text(
            'Voulez-vous réserver ce livre physique ?\n'
                'Vous pourrez le récupérer à la bibliothèque.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) await vm.reserverLivre(idBook,duree);
  }

  // ── État erreur ─────────────────────────────────────────────────────
  Widget _buildErrorState(BookViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.wifi_off, size: 80, color: Colors.orange)
              .animate(onPlay: (c) => c.repeat())
              .shake(duration: 500.ms, hz: 2),
          const SizedBox(height: 24),
          Text(vm.errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<BookViewModel>().chargerDetail(numero, idBook),
            icon : const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// BARRE DE PROGRESSION AYANT LA MÊME FORME QUE LE BOUTON
// ══════════════════════════════════════════════════════════════════════
class _BarreProgressionBouton extends StatelessWidget {
  final double progress;  // 0.0 → 1.0  |  -1 = indéterminé
  final Color  couleur;
  final String label;

  const _BarreProgressionBouton({
    required this.progress,
    required this.couleur,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool indetermine = progress < 0;
    final String pct = indetermine
        ? label
        : '${(progress * 100).toStringAsFixed(0)}%';

    return Container(
      height    : 36,
      decoration: BoxDecoration(
        // Fond gris clair identique à la forme du bouton
        color        : couleur.withOpacity(0.15),
        borderRadius : BorderRadius.circular(20),
        border       : Border.all(color: couleur.withOpacity(0.4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        // ── Remplissage animé ────────────────────────────────────────
        AnimatedFractionallySizedBox(
          duration       : const Duration(milliseconds: 300),
          widthFactor    : indetermine ? 0.0 : progress.clamp(0.0, 1.0),
          alignment      : Alignment.centerLeft,
          child          : Container(
            decoration: BoxDecoration(
              color        : couleur,
              borderRadius : BorderRadius.circular(20),
            ),
          ),
        ),

        // ── Si indéterminé : shimmer animé ────────────────────────
        if (indetermine)
          _ShimmerBarre(couleur: couleur),

        // ── Texte centré par-dessus ───────────────────────────────
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!indetermine) ...[
                Text(
                  pct,
                  style: TextStyle(
                    fontSize   : 12,
                    fontWeight : FontWeight.bold,
                    color      : progress > 0.5
                        ? Colors.white
                        : couleur,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: 12, height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color      : couleur,
                  ),
                ),
                const SizedBox(width: 6),
                Text(pct,
                    style: TextStyle(
                        fontSize: 11, color: couleur,
                        fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Shimmer pour progression indéterminée ─────────────────────────────
class _ShimmerBarre extends StatefulWidget {
  final Color couleur;
  const _ShimmerBarre({required this.couleur});
  @override
  State<_ShimmerBarre> createState() => _ShimmerBarreState();
}

class _ShimmerBarreState extends State<_ShimmerBarre>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => FractionallySizedBox(
        widthFactor: 1.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end  : Alignment(_anim.value,     0),
              colors: [
                widget.couleur.withOpacity(0.05),
                widget.couleur.withOpacity(0.25),
                widget.couleur.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../appstate.dart';
import '../view_models/book_view_model.dart';

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
                  textAlign: TextAlign.center,
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


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
        );
      },
    );
  }

  Widget _buildBody(BookViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage.isNotEmpty) {
      return _buildErrorState(vm);
    }


    return _buildContentState(vm);
  }

  // Cette méthode ne retourne PLUS un Scaffold, mais juste le contenu
  Widget _buildContentState(BookViewModel vm) {
    final detail = vm.livreDetail!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //info du livre

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
    child: Image.network("${AppState.baseUrlCover}${detail.numberNoLike}/blankets/${detail.bookBlanket}",

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

    ).animate(delay: (2 * 100).ms).fadeIn(),
    SizedBox(width: 20,),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
    SizedBox(height: 30,),
    Text('${detail.bookTitle}',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 14,),),
    SizedBox(height: 10,),
    Text('De: ${detail.firstName ?? ""} ${detail.name ?? ""}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Colors.grey),),
    SizedBox(height: 10,),
    Text('Catégorie: ${detail.categoryTitle}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Colors.grey),),

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
      detail.isPhysic ==true ?Icon(Icons.menu_book_sharp,color: Colors.green,size: 15,):SizedBox(),
    const SizedBox(width: 4),
      detail.electronic !='' ?Icon(Icons.picture_as_pdf,color: Colors.green,size: 15,):SizedBox(),
    const SizedBox(width: 4),
      detail.isAudio ==true ?Icon(Icons.audiotrack,color: Colors.green,size: 15,):SizedBox(),
    const SizedBox(width: 4),

    Icon(Icons.notifications_none_sharp,color: Colors.green,size: 15,),
    Text("0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),),

    const SizedBox(width: 10),
    Icon(Icons.visibility_sharp,color: Colors.green,size: 15,),
    Text(detail.numberView.toString()??"0",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),)


    ],
    ),


    ],
    ),
    ),

    ],
    ),
    )


          ],
      ),
    );
  }

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
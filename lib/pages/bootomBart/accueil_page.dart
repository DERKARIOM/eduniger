/*
import 'dart:async';

import 'package:eduniger/models/modelBook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/modelAutheur.dart';
import '../../models/modelStructure.dart';
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  List<String> publications = [
    'assets/pub/1.png',
    'assets/pub/2.png',
    'assets/pub/6.png',
  ];
  List<Book> couverture = [];
  List<Structure> structure =[] ;
  List<Author> auteurs = [];
// Auto-scroll de publications

  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void _autoSwitch() async {
    // On attend que le premier frame soit dessiné pour être sûr que le PageController est attaché
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      // On utilise !mounted pour arrêter la boucle si l'utilisateur quitte la page
      while (mounted) {
        await Future.delayed(const Duration(seconds: 4));

        // Vérification indispensable avant toute manipulation du controller
        if (_pageController.hasClients) {
          _currentPage++;

          if (_currentPage >= publications.length) {
            _currentPage = 0;
          }

          // Utiliser animateToPage est plus joli que jumpToPage pour un slider
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
// fin  Auto-scroll de publications

  @override
  void initState() {
    super.initState();
    _autoSwitch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
          //Les publications
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: publications.length,
              physics: const NeverScrollableScrollPhysics(), // optionnel
              itemBuilder: (context, index) {
                return
                  Container(

                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),

                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),


                  ),
                  child:ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      publications[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                );
              },
            ),
          ),

          /*
            Container(
              height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
              //width: 300,
              child:
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: publications.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Image.asset(
                      publications[index],
                      fit: BoxFit.cover,
                    ),
                  ).animate(delay: (index * 100).ms)
                      .fadeIn()
                      .slideX(begin: 0.3, end: 0);

                },
              )

            ),
            */
            const SizedBox(height: 30),
            //ajouter un contenu
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/images/add_auteurs.png'),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                      .moveY(
                    begin: 0,
                    end: -15, // monte de 15 pixels
                    duration: 800.ms,
                    curve: Curves.easeInOut,
                  ),
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Ajouter un contenu",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                          const Text("Créez librement"),

                        ],
                      ),
                    ),

                  Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,

                      borderRadius: BorderRadius.circular(30),
                    ),


                      child: TextButton(onPressed: (){}, child: Text("Ajouter",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.white),)))
                ],
              ),
            ),
            //const SizedBox(height: 10),
            //voir les livres
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Text('Recomandés',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  Spacer(),
                  const Text('Voir plus',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green),),



                ],

              ),
            ),
          //liste des livres
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: couverture.length < 6 ? couverture.length : 7,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),


                    ),
                    child:ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        couverture[index].couverture!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 150,
                      ),
                    ),
                  ).animate(delay: (index * 100).ms)
                      .fadeIn();

                }
              ),


            ),
        // voir des structures
           Padding(
          padding:  const EdgeInsets.all(10),
          child: Row(
          children: [
            const Text('Structure', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Spacer(), // Spacer est plus propre qu'un Expanded avec un SizedBox
            const Text('Voir plus', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
          //liste des structures
           ListView.builder(
          shrinkWrap: true, // Indique à la ListView de prendre seulement la place nécessaire
          physics: const NeverScrollableScrollPhysics(), // Empêche cette ListView de défiler (le SingleChildScrollView s'en charge)
          itemCount: structure.length < 6 ? structure.length : 6, // J'ai corrigé votre logique ici pour afficher jusqu'à 6 éléments
          itemBuilder: (context, index) {
            return Container(
              // Le ListTile est plus adapté pour ce layout
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                leading: CircleAvatar(
                  radius: 35, // Augmenté pour un meilleur aspect
                  backgroundImage: AssetImage(structure[index].logo),
                ),
                title: Text(
                  structure[index].name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${structure[index].bookNumber} livres",
                  style: TextStyle(fontSize: 13),
                ),
                trailing: Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    color: structure[index].isAdhere ? Colors.black45 : Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      structure[index].isAdhere ? "Adhéré" : "S'adhérer", // Texte dynamique
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
            SizedBox(height: 5,),
            // voir des auteurs
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Text('Auteurs',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  Expanded(child: const SizedBox(width: 10),),
                  const Text('Voir plus',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green),),



                ],

              ),
            ),
           SizedBox(height: 5,),
          //liste des auteurs
           SizedBox(
          height: 110,

      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: auteurs.length < 6 ? auteurs.length : 6,
          itemBuilder: (context, index) {
            return
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(auteurs[index].profile!),
                  ),
                  const SizedBox(height: 5,),
                  Text(auteurs[index].name,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),




                ],
                            ),
              );
          })
      ),
          ],
      )
      )
    );
  }
}
*/

import 'dart:async';
import 'package:eduniger/models/modelBook.dart';
import 'package:eduniger/models/modelUser.dart';
import 'package:eduniger/pages/Commun/detailBook.dart';
import 'package:eduniger/services/adhere_structure_api.dart' hide AuthService;
import 'package:eduniger/services/detache_structure_api.dart';
import 'package:fl_custom_image_view/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/modelAutheur.dart';
import '../../models/modelStructure.dart';
import '../../services/recomandation_api.dart';
import 'bibliotheque_page.dart';

class AccueilPage extends StatefulWidget {
  final String IdNumber;
  final String Version;

  const AccueilPage({
    super.key,

    required this.IdNumber,
    required this.Version,

  });

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  //final String baseUrl = "https://votre-domaine.com/images/logos/";
  static const String baseUrl = 'https://eduniger.com/ressources/cover/';
  static const String baseUrlProfile = 'https://eduniger.com/ressources/profile/';
  List<String> publications = [
    'assets/pub/1.png',
    'assets/pub/2.png',
    'assets/pub/6.png',
  ];

  // Données chargées depuis l'API
  List<Book> couverture = [];
  List<Structure> structure = [];
  List<Structure> structureAdd = [];
  //List<Structure> structureRecom = [];
  List<Author> auteurs = [];

  // Future pour FutureBuilder
  late Future<Map<String, dynamic>> _dataFuture;

  // Controllers
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();


    _loadData();
    _autoSwitch();
  }

  // Charger les données depuis l'API

  void _loadData() {
    setState(() {
      _dataFuture = RecommendationService.getAllRecommendations(
        idNumber: widget.IdNumber,
        version: widget.Version,
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException('Le chargement prend trop de temps. Vérifiez votre connexion.');
        },
      );
    });
  }
  //gestion pour adherer a une structure
  void _handleStructureAction(int index) async {
    // On récupère l'élément actuel
    final currentItem = structureAdd[index];

    if (currentItem.isAdhere) {
      // --- LOGIQUE DE DÉTACHEMENT ---
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black45,
          title: const Text("Se détacher",style: TextStyle(fontSize: 14,color: Colors.white),),
          content: Text("Voulez-vous vraiment vous détacher de ${currentItem.name} ?",style: TextStyle(fontSize: 12,color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler",style: TextStyle(fontSize: 12,color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirmer", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;

      if (confirm) {
        try {
          final response = await DetacheStructureApi.detacher(
            id_number: widget.IdNumber,
            id: currentItem.id.toString(),
          );

          if (response.status == 'success') {
            _toggleLocalState(index); // MISE À JOUR ICI
            _showSnackBar('Vous etes détaché avec succès !', Colors.green);
          } else {
            _showSnackBar(response.message ?? "Erreur lors du détachement", Colors.orange);
          }
        } catch (e) {
          _showSnackBar('Erreur de connexion', Colors.red);
        }
      }
    } else {
      // --- LOGIQUE D'ADHÉSION ---
      try {
        final response = await Aderers.adhere(
          id_number: widget.IdNumber,
          idStructure: currentItem.id.toString(),
        );

        if (response.status == 'success') {
          _toggleLocalState(index); // MISE À JOUR ICI
          _showSnackBar('Vous avez adhéré avec succès !', Colors.green);
        } else {
          _showSnackBar(response.message ?? "Erreur lors de l'adhésion", Colors.orange);
        }
      } catch (e) {
        _showSnackBar('Erreur de connexion', Colors.red);
      }
    }
  }

// Petite fonction utilitaire pour alléger le code des SnackBars
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // Fonction pour mettre à jour l'état local de bouton structure

  void _toggleLocalState(int index) {
    if (!mounted) return;
    setState(() {
      // 1. Créer une copie de l'élément modifié
      final updatedStructure = structureAdd[index].copyWith(
        isAdhere: !structureAdd[index].isAdhere,
      );

      structureAdd[index] = updatedStructure;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      structureAdd.clear(); // Important pour forcer le FutureBuilder à re-remplir la liste
    });
    _loadData();
    await _dataFuture;
  }

  // Auto-scroll publications
  void _autoSwitch() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      while (mounted) {
        await Future.delayed(const Duration(seconds: 4));
        if (_pageController.hasClients) {
          _currentPage++;
          if (_currentPage >= publications.length) {
            _currentPage = 0;
          }
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          // ===== GESTION DES ÉTATS =====

          // 1. CHARGEMENT
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // 2. ERREUR
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // 3. DONNÉES NULLES
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState();
          }

          // 4. EXTRACTION CORRECTE DES DONNÉES

          final data = snapshot.data!;
          // 4. EXTRACTION CORRECTE DES DONNÉES

        // Extraction sécurisée via vos objets ApiResponse déjà existants
          final booksResponse = data['recommendedBooks'] as ApiResponse<List<Book>>;
          final structuresAddResponse = data['joinedStructures'] as ApiResponse<List<Structure>>;
          final structuresRecomResponse = data['recommendedStructures'] as ApiResponse<List<Structure>>;
          final authorsResponse = data['recommendedAuthors'] as ApiResponse<List<Author>>;

          print('Books response success: ${booksResponse.success}');
          print('Books data null?: ${booksResponse.data == null}');
          print('Books count: ${booksResponse.data?.length ?? 0}');

          print('Structures response success: ${structuresAddResponse.success}');
          print('Structures data null?: ${structuresAddResponse.data == null}');
          print('Structures count: ${structuresAddResponse.data?.length ?? 0}');

          print('Structures response success: ${structuresRecomResponse.success}');
          print('Structures data null?: ${structuresRecomResponse.data == null}');
          print('Structures count: ${structuresRecomResponse.data?.length ?? 0}');

          print('Authors response success: ${authorsResponse.success}');
          print('Authors data null?: ${authorsResponse.data == null}');
          print('Authors count: ${authorsResponse.data?.length ?? 0}');



        // CORRECTION : Mise à jour de la liste locale des structures uniquement si elle est vide
        // Cela permet à _toggleLocalState de garder ses changements après un setState
          couverture = booksResponse.data ?? [];
          auteurs = authorsResponse.data ?? [];

          if (structureAdd.isEmpty) {
            // On récupère les données des réponses API
            final List<Structure> joined = structuresAddResponse.data ?? [];
            final List<Structure> recom = structuresRecomResponse.data ?? [];

            // On s'assure que le flag isAdhere est bien positionné au départ
            final joinedMapped = joined.map((s) => s.copyWith(isAdhere: true)).toList();
            final recomMapped = recom.map((s) => s.copyWith(isAdhere: false)).toList();

            // Fusion et limite à 6
            structureAdd = [...joinedMapped, ...recomMapped].toList();
            print('StructureAdd fusionnée : ${structureAdd.length} éléments');
          }

          return _buildContentState();


        /*
          print('Data keys: ${data.keys}');

          // Extraction avec vérification
          final booksResponse = data['recommendedBooks'] as ApiResponse<List<Book>>;
          final structuresAdd = data['joinedStructures'] as ApiResponse<List<Structure>>;
          final structuresRecom = data['recommendedStructures'] as ApiResponse<List<Structure>>;
          final authorsResponse = data['recommendedAuthors'] as ApiResponse<List<Author>>;


          print('Books response success: ${booksResponse.success}');
          print('Books data null?: ${booksResponse.data == null}');
          print('Books count: ${booksResponse.data?.length ?? 0}');

          print('Structures response success: ${structuresAdd.success}');
          print('Structures data null?: ${structuresAdd.data == null}');
          print('Structures count: ${structuresAdd.data?.length ?? 0}');

          print('Structures response success: ${structuresRecom.success}');
          print('Structures data null?: ${structuresRecom.data == null}');
          print('Structures count: ${structuresRecom.data?.length ?? 0}');

          print('Authors response success: ${authorsResponse.success}');
          print('Authors data null?: ${authorsResponse.data == null}');
          print('Authors count: ${authorsResponse.data?.length ?? 0}');

// Mise à jour des listes locales
          couverture = booksResponse.data ?? [];
          /*
          structureAdd = structuresAdd.data ?? [];
          structureRecom = structuresRecom.data ?? [];
          structure = structureAdd + structureRecom;
          */

          // Mise à jour de la liste locale limitée à 6
          if (structureAdd.isEmpty) {
            // Votre logique de regroupement ici
            final List<Structure> joined = (snapshot.data!['structuresAdd'] as List)
                .map((json) => Structure.fromJson(json, isAdhere: true)).toList();
            final List<Structure> recom = (snapshot.data!['structuresRecom'] as List)
                .map((json) => Structure.fromJson(json, isAdhere: false)).toList();

            structureAdd = [...joined, ...recom].take(6).toList();
          }

          structureAdd.take(7).toList();
          auteurs = authorsResponse.data ?? [];

          print('\n✅ UI Lists updated:');
          print('  - couverture: ${couverture.length}');
          print('  - structure: ${structure.length}');
          print('  - auteurs: ${auteurs.length}');
          print('======================================\n');

// Vérifier si toutes les listes sont vides
          if (couverture.isEmpty && structure.isEmpty && auteurs.isEmpty) {
            print('⚠️ WARNING: All lists are empty!');
            // Vous pouvez retourner l'état vide ici si vous voulez
            // return _buildEmptyState();
          }

          // 5. AFFICHAGE DU CONTENU
          return _buildContentState();
          return RefreshIndicator(
          onRefresh: _onRefresh,
          child: _buildContentState(),
          );
          */
        },
      ),
    );
  }

  // ==================== ÉTATS UI ====================

  /// État de chargement avec shimmer
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Shimmer pour publications
          _buildShimmerBox(height: 180, borderRadius: 10),

          const SizedBox(height: 30),

          // Shimmer pour "Ajouter un contenu"
          _buildShimmerBox(height: 100),

          const SizedBox(height: 20),

          // Shimmer pour "Recommandés"
          _buildSectionShimmer('Recommandés', isHorizontal: true),

          const SizedBox(height: 20),

          // Shimmer pour "Structures"
          _buildSectionShimmer('Structures', isHorizontal: false),

          const SizedBox(height: 20),

          // Shimmer pour "Auteurs"
          _buildSectionShimmer('Auteurs', isHorizontal: true),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    double? width,
    double borderRadius = 8,
  }) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),

    );
  }

  Widget _buildSectionShimmer(String title, {required bool isHorizontal}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isHorizontal)
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildShimmerBox(
                  height: 150,
                  width: 100,
                  borderRadius: 10,
                );
              },
            ),
          )
        else
          Column(
            children: List.generate(
              3,
                  (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                child: Row(
                  children: [
                    _buildShimmerBox(height: 70, width: 70, borderRadius: 35),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(height: 16, width: 150),
                          const SizedBox(height: 8),
                          _buildShimmerBox(height: 14, width: 100),
                        ],
                      ),
                    ),
                    _buildShimmerBox(height: 35, width: 100, borderRadius: 30),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// État d'erreur avec diagnostic
  Widget _buildErrorState(String error) {
    IconData errorIcon;
    String errorTitle;
    String errorMessage;
    Color errorColor;

    // Diagnostic du type d'erreur
    if (error.contains('connexion') ||
        error.contains('network') ||
        error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      errorIcon = Icons.wifi_off;
      errorTitle = 'Pas de connexion';
      errorMessage = 'Vérifiez votre connexion Internet et réessayez.';
      errorColor = Colors.orange;
    } else if (error.contains('timeout') || error.contains('trop de temps')) {
      errorIcon = Icons.access_time;
      errorTitle = 'Délai dépassé';
      errorMessage = 'Le serveur met trop de temps à répondre.';
      errorColor = Colors.amber;
    } else if (error.contains('401') || error.contains('Non autorisé')) {
      errorIcon = Icons.lock;
      errorTitle = 'Non autorisé';
      errorMessage = 'Votre session a expiré. Reconnectez-vous.';
      errorColor = Colors.red;
    } else if (error.contains('404') || error.contains('non trouvée')) {
      errorIcon = Icons.search_off;
      errorTitle = 'Ressource introuvable';
      errorMessage = 'Les données demandées n\'existent pas.';
      errorColor = Colors.blue;
    } else if (error.contains('500') || error.contains('serveur')) {
      errorIcon = Icons.error;
      errorTitle = 'Erreur serveur';
      errorMessage = 'Le serveur rencontre un problème.';
      errorColor = Colors.red;
    } else {
      errorIcon = Icons.warning;
      errorTitle = 'Erreur ';
      errorMessage = error;
      errorColor = Colors.grey;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorIcon,
              size: 80,
              color: errorColor,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shake(duration: 500.ms, hz: 2),

            const SizedBox(height: 24),

            Text(
              errorTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: errorColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Bouton réessayer
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                Spacer(),
                //const SizedBox(height: 16),

                // Détails techniques (optionnel)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BibliothequePage()),
                    );
                  },
                  child: const Text(
                    'Bibliothèque local',
                    style: TextStyle(color: Colors.grey),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
              ],
            ),

          ],
        ),
      ),
    );
  }

  /// État vide (aucune donnée disponible)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey[400],
            ).animate().fadeIn().scale(),

            const SizedBox(height: 24),

            const Text(
              'Aucune recommandation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Commencez à explorer pour obtenir des recommandations personnalisées.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// État de succès (contenu principal)
  Widget _buildContentState() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.green,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        physics: const AlwaysScrollableScrollPhysics(), // Important pour le RefreshIndicator
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Les publications
            _buildPublicationsSection(),

            const SizedBox(height: 30),

            // Ajouter un contenu
            _buildAddContentSection(),

            // Livres recommandés
            _buildRecommendedBooksSection(),

            // Structures
            _buildStructuresSection(),

            const SizedBox(height: 5),

            // Auteurs
            _buildAuthorsSection(),
          ],
        ),
      ),
    );
  }

  // ==================== SECTIONS DU CONTENU ====================

  Widget _buildPublicationsSection() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemCount: publications.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                publications[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
          );
        },
      ),
    );
  }

  Widget _buildAddContentSection() {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage: const AssetImage('assets/images/add_auteurs.png'),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).moveY(
            begin: 0,
            end: -15,
            duration: 800.ms,
            curve: Curves.easeInOut,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Ajouter un contenu",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text("Créez librement"),
              ],
            ),
          ),
          Container(
            height: 35,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Ajouter",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedBooksSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: const [
              Text(
                'Recommandés',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Voir plus',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),

        // Gestion du cas vide
        if (couverture.isEmpty)
          _buildEmptySection('Aucun livre recommandé pour le moment')
        else
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: couverture.length < 6 ? couverture.length : 6,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder:(context)=>Detailbook(
                        idBook:couverture[index].idBook!,
                        idUser: widget.IdNumber) ));
                  } ,
                  child:
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child:  ClipRRect(

                      borderRadius: BorderRadius.circular(10),
                  child: Image.network( '$baseUrl${couverture[index].blanket!}',
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


                  ).animate(delay: (index * 100).ms).fadeIn(),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStructuresSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: const [
              Text(
                'Structure',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Voir plus',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),

        if (structureAdd.isEmpty)
          _buildEmptySection('Aucune structure disponible')
        else

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: structureAdd.length < 7 ? structureAdd.length : 7,
            itemBuilder: (context, index) {
              return
                ListTile(

                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                leading: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[200], // Couleur de fond si l'image échoue
                  backgroundImage: (structureAdd[index].logo != null && structureAdd[index].logo!.isNotEmpty)
                      ? NetworkImage('$baseUrl${structureAdd[index].logo}')
                      : null,
                  // Gestion de l'erreur de chargement réseau
                  onBackgroundImageError: (exception, stackTrace) {
                    print("Erreur de chargement du logo: $exception");
                  },
                  // L'icône enfant ne s'affiche que si backgroundImage est null
                  child: (structureAdd[index].logo == null || structureAdd[index].logo!.isEmpty)
                      ? const Icon(Icons.business, color: Colors.grey)
                      : null,
                ),

                title: Text(
                  structureAdd[index].name??'',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${structureAdd[index].bookNumber} livres",
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    // Noir/Gris si déjà adhéré, Vert sinon
                    color: structureAdd[index].isAdhere ? Colors.black45 : Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () => _handleStructureAction(index), // Utilise la nouvelle logique
                    child: Text(
                      structureAdd[index].isAdhere ? "Détacher" : "S'adhérer",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAuthorsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: const [
              Text(
                'Auteurs',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Voir plus',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),

        if (auteurs.isEmpty)
          _buildEmptySection('Aucun auteur recommandé')
        else
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: auteurs.length < 6 ? auteurs.length : 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200], // Fond gris clair plus visible que white12
                        backgroundImage: (auteurs[index].profile != null && auteurs[index].profile!.isNotEmpty)
                            ? NetworkImage('$baseUrlProfile${auteurs[index].profile}')
                            : null,
                        onBackgroundImageError: (exception, stackTrace) {
                          // Cette fonction attrape l'erreur si l'image 404 ou URL invalide
                          print("Erreur chargement profil auteur: $exception");
                        },
                        child: (auteurs[index].profile == null || auteurs[index].profile!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        auteurs[index].name??'',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
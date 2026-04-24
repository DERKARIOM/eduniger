import 'package:eduniger/features/livres/dto/book_dto.dart';
import 'package:eduniger/features/utilisateurs/view_models/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../appstate.dart';
import '../../autheurs/model/author_model.dart';
import '../../livres/models/book_model.dart';
import '../../structures/model/structure_model.dart';
import '../view_model/accueil_view_model.dart';
class AccueilView extends StatefulWidget {
  const AccueilView({Key? key}) : super(key: key);

  @override
  State<AccueilView> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilView> {
  AppState get appState => context.watch<AppState>();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AccueilViewModel>().chargerAccueil();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccueilViewModel>().chargerAccueil();
    });

    _startAutoScroll();
  }

  /*
  @override
  void initState() {
    super.initState();

    // Accédez à AppState
  //  final appState = context.read<AppState>();

    // Initialisez le ViewModel de l'accueil via AppState
    // (Assurez-vous d'avoir une méthode similaire à initialiserLivresVM dans votre AppState)
    appState.initialiserAccueilVM(
      appState.numeroUtilisateur,
      appState.version,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Appelez vos méthodes de chargement sur l'instance dans AppState
      appState.accueilVM.chargerAccueil();
        });
    _startAutoScroll();
  }
*/
  void _startAutoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      while (mounted) {
        await Future.delayed(const Duration(seconds: 4));
        if (!mounted || !_pageController.hasClients) return;
        final vm = context.read<AccueilViewModel>();
        _currentPage = (_currentPage + 1) % vm.publications.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── SnackBar centralisé ────────────────────────────────────────────────
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Traduction des actionMessage (même logique que ton _handleStructureAction)
  void _handleActionMessage(AccueilViewModel vm) {
    if (vm.actionMessage.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (vm.actionMessage) {
        case 'adhere_ok':
          _showSnackBar('Vous avez adhéré avec succès !',    Colors.green);  break;
        case 'detache_ok':
          _showSnackBar('Vous êtes détaché avec succès !',   Colors.green);  break;
        default:
          _showSnackBar(vm.actionMessage,                    Colors.orange); break;
      }
      vm.clearActionMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccueilViewModel>(
      builder: (context, vm,_) {
        //final AccueilViewModel vm = appState.accueilVM;
        _handleActionMessage(vm);

        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildBody(vm),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // CORPS — 3 états (même logique que ton FutureBuilder)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildBody(AccueilViewModel vm) {
    //print('$_baseUrlCover''logos/''logo.png');
    if (vm.isLoading && vm.livresRecomandes.isEmpty)               return _buildLoadingState();
    if (vm.errorMessage.isNotEmpty && vm.livresRecomandes.isEmpty) return _buildErrorState(vm);
    return _buildContentState(vm);
  }

  // ══════════════════════════════════════════════════════════════════════
  // ÉTAT CHARGEMENT — shimmer identique à l'ancien
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(5),
      child: Column(children: [
        const SizedBox(height: 20),
        _shimmerBox(height: 180, borderRadius: 10),
        const SizedBox(height: 30),
        _shimmerBox(height: 100),
        const SizedBox(height: 20),
        _shimmerSection(isHorizontal: true),
        const SizedBox(height: 20),
        _shimmerSection(isHorizontal: false),
        const SizedBox(height: 20),
        _shimmerSection(isHorizontal: true),
      ]),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double borderRadius = 8,
  }) {
    return Container(
      height: height, width: width,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _shimmerSection({required bool isHorizontal}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            _shimmerBox(height: 20, width: 120, borderRadius: 4),
            const Spacer(),
            _shimmerBox(height: 20, width: 80, borderRadius: 4),
          ]),
        ),
        const SizedBox(height: 12),
        isHorizontal
            ? SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (_, __) =>
                _shimmerBox(height: 150, width: 100, borderRadius: 10),
          ),
        )
            : Column(
          children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 10),
            child: Row(children: [
              _shimmerBox(height: 70, width: 70, borderRadius: 35),
              const SizedBox(width: 12),
              Expanded(child: Column(children: [
                _shimmerBox(height: 16, width: 150),
                const SizedBox(height: 8),
                _shimmerBox(height: 14, width: 100),
              ])),
              _shimmerBox(height: 35, width: 100, borderRadius: 30),
            ]),
          )),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // ÉTAT ERREUR — diagnostic identique à l'ancien _buildErrorState
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildErrorState(AccueilViewModel vm) {
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
                    onPressed: vm.chargerAccueil,
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

  // ══════════════════════════════════════════════════════════════════════
  // CONTENU PRINCIPAL
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildContentState(AccueilViewModel vm) {
    return RefreshIndicator(
      // ← vm.rafraichir() vide les structures avant de recharger
      onRefresh : vm.rafraichir,
      color     : Colors.green,
      child     : SingleChildScrollView(
        padding : const EdgeInsets.all(5),
        physics : const AlwaysScrollableScrollPhysics(),
        child   : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _sectionPublications(vm),
            const SizedBox(height: 30),
            _sectionAjoutContenu(),
            _sectionLivresRecomandes(vm),
            _sectionStructures(vm),
            const SizedBox(height: 5),
            _sectionAuteurs(vm),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // SECTION 1 — PUBLICATIONS (auto-scroll identique à l'ancien)
  // ══════════════════════════════════════════════════════════════════════
  Widget _sectionPublications(AccueilViewModel vm) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller  : _pageController,
        itemCount   : vm.publications.length,
        physics     : const NeverScrollableScrollPhysics(),
        itemBuilder : (_, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              vm.publications[index],
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
          end  : const Offset(1.0,  1.0),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // SECTION 2 — AJOUT DE CONTENU
  // ══════════════════════════════════════════════════════════════════════
  Widget _sectionAjoutContenu() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage:
            const AssetImage('assets/images/add_auteurs.png'),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -15, duration: 800.ms,
              curve: Curves.easeInOut),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ajouter un contenu',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Créez librement'),
              ],
            ),
          ),
          Container(
            height: 35, width: 100,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextButton(
              onPressed: () {/* TODO */},
              child: const Text('Ajouter',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // SECTION 3 — LIVRES RECOMMANDÉS
  // Utilise book.idBook et book.blanket comme dans ton ancien code
  // ══════════════════════════════════════════════════════════════════════
  Widget _sectionLivresRecomandes(AccueilViewModel vm) {
    return Column(children: [
      _entete('Recommandés', onVoirPlus: () {}),
      vm.livresRecomandes.isEmpty
          ? _sectionVide('Aucun livre recommandé pour le moment')
          : SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: vm.livresRecomandes.length.clamp(0, 6),
          itemBuilder: (_, index) {
            final Book book = vm.livresRecomandes[index];
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
                  // ← book.blanket exactement comme dans l'ancien code
                  child: Image.network(
                    //'$_baseUrlCover${book.blanket ?? ''}',
                    "${AppState.baseUrlCover}${book.dStructures}/blankets/${book.blanket}",
                    //"$_baseUrlCover${book.idStruct}/blankets/${book.blanket}",
                    fit: BoxFit.cover,
                    width: 100, height: 150,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100, height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
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
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════
  // SECTION 4 — STRUCTURES
  // Utilise s.name, s.logo, s.bookNumber, s.isAdhere de ton Structure
  // ══════════════════════════════════════════════════════════════════════
  Widget _sectionStructures(AccueilViewModel vm) {

    return Column(children: [
      _entete('Structures', onVoirPlus: () {}),
      vm.structures.isEmpty
          ? _sectionVide('Aucune structure disponible')
          : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vm.structures.length.clamp(0, 7),
        itemBuilder: (_, index) {
          final Structure s = vm.structures[index];
          return ListTile(

            contentPadding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 8),
            leading: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey[200],
              backgroundImage:
              (s.logo != null && s.logo!.isNotEmpty)
                  ? NetworkImage(
                  //"$_baseUrlCover${s.id}/logos/${s.logo}"
                    "${AppState.baseUrlCover}${s.id}/logos/${s.logo}"
                    )
                  : null,
              onBackgroundImageError: (e, _) =>
                  debugPrint('Logo erreur : $e'),
              child: (s.logo == null || s.logo!.isEmpty)
                  ? const Icon(Icons.business, color: Colors.grey)
                  : null,
            ),
            title: Text(s.name ?? '',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            subtitle: Text('${s.bookNumber ?? 0} livres',
                style: const TextStyle(fontSize: 13)),
            trailing: Container(
              height: 35, width: 100,
              decoration: BoxDecoration(
                color: s.isAdhere ? Colors.black45 : Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextButton(
                // ← dialog dans la View, action déléguée au ViewModel
                onPressed: () =>
                    _confirmerToggleStructure(vm, index),
                child: Text(
                  s.isAdhere ? 'Détacher' : "S'adhérer",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }

  // Dialog de confirmation (responsabilité de la View)
  // Identique à la logique de ton ancien _handleStructureAction
  Future<void> _confirmerToggleStructure(
      AccueilViewModel vm, int index) async
  {
    final Structure s = vm.structures[index];

    if (s.isAdhere) {
      // ← même dialog que ton ancien code
      final bool confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black45,
          title: const Text('Se détacher',
              style: TextStyle(fontSize: 14, color: Colors.white)),
          content: Text(
            'Voulez-vous vraiment vous détacher de ${s.name} ?',
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmer',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
          false;

      if (!confirm) return;
    }

    // ← action déléguée au ViewModel
    await vm.toggleStructure(index);
  }

  // ══════════════════════════════════════════════════════════════════════
  // SECTION 5 — AUTEURS
  // Utilise a.name et a.profile de ton Author (hérités de User)
  // ══════════════════════════════════════════════════════════════════════
  Widget _sectionAuteurs(AccueilViewModel vm) {
    return Column(children: [
      _entete('Auteurs', onVoirPlus: () {}),
      const SizedBox(height: 5),
      vm.auteurs.isEmpty
          ? _sectionVide('Aucun auteur recommandé')
          : SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: vm.auteurs.length.clamp(0, 6),
          itemBuilder: (_, index) {
            final Author a = vm.auteurs[index];
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (a.profile.isNotEmpty)
                        ? NetworkImage(
                        //'$_baseUrlProfile${a.profile}'
                            "${AppState.baseUrlProfile}${a.profile}"
                          )
                        : null,
                    onBackgroundImageError: (e, _) =>
                        debugPrint('Profile erreur : $e'),
                    child: (a.profile == null || a.profile!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 5),
                  // ← a.name hérité de User (ton modèle existant)
                  Text(a.name ?? '',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ── Widgets utilitaires ────────────────────────────────────────────────
  Widget _entete(String titre, {required VoidCallback onVoirPlus}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        Text(titre,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
        const Spacer(),
        GestureDetector(
          onTap: onVoirPlus,
          child: const Text('Voir plus',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ),
      ]),
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
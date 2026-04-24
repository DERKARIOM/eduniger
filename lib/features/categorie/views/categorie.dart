import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../appstate.dart';
import '../models/modelCategorie.dart';
import '../view_model/categorie_view_model.dart';


class Categorie extends StatefulWidget {
  const Categorie({super.key});

  @override
  State<Categorie> createState() => _CategorieState();
}

class _CategorieState extends State<Categorie> {
  AppState get appState => context.watch<AppState>();

  //List<MCategorie> mcategorie = [];
  @override
  Widget build(BuildContext context) {
    return
      Consumer<CategorieViewModel>(
        builder: (context, vm, _) {

          return _buildBody(vm);

        },
      );
  }
  Widget _buildBody(CategorieViewModel vm) {
    //print('$_baseUrlCover''logos/''logo.png');
    if (vm.isLoading && vm.mcategorie.isEmpty)               return _buildLoadingState();
    if (vm.errorMessage.isNotEmpty && vm.mcategorie.isEmpty) return _buildErrorState(vm);
    return _buildContentState(vm);
  }
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
    Widget _buildContentState(CategorieViewModel vm) {
      return  Scaffold(
        backgroundColor: Colors.white,

        body:
        ListView.builder(
            shrinkWrap: true, // Indique à la ListView de prendre seulement la place nécessaire
            //physics: const NeverScrollableScrollPhysics(), // Empêche cette ListView de défiler (le SingleChildScrollView s'en charge)
            itemCount: vm.mcategorie.length,
            itemBuilder: (context, index) {
              final cat = vm.mcategorie[index];
              return
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
                  child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  leading:
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (vm.mcategorie[index].cover != null && vm.mcategorie[index].cover!.isNotEmpty)
                        ? NetworkImage(
                      //'$_baseUrlProfile${a.profile}'
                        "${AppState.baseUrlProfile}${vm.mcategorie[index].cover}"
                    )
                        : null,
                    onBackgroundImageError: (e, _) =>
                        debugPrint('Profile erreur : $e'),
                    child: (vm.mcategorie[index].cover == null || vm.mcategorie[index].cover!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  title: Text(
                    cat.name ?? 'Non spécifier',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                                ),
                );
            }),
      );
    }
  Widget _buildErrorState(CategorieViewModel vm) {
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
                    onPressed: vm.chargerCategorie,
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



import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../appstate.dart';
import '../model/structure_model.dart';
import '../view_model/structure_view_model.dart';



class StructurePage extends StatefulWidget {
  const StructurePage({super.key});

  @override
  State<StructurePage> createState() => _StructureState();
}

class _StructureState extends State<StructurePage> {
  AppState get appState => context.watch<AppState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<StructureViewModel>(
      builder: (context, vm, _) {
        return _buildBody(vm);
      },
    );
  }
  Widget _buildBody(StructureViewModel vm) {
    //print('$_baseUrlCover''logos/''logo.png');
    if (vm.isLoading && vm.structures.isEmpty)               return _buildLoadingState();
    if (vm.errorMessage.isNotEmpty && vm.structures.isEmpty) return _buildErrorState(vm);
    return _buildContentState(vm);
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  Widget _buildContentState(StructureViewModel vm) {
    return  Scaffold(
      backgroundColor: Colors.white,

      body: ListView.builder(
          shrinkWrap: true, // Indique à la ListView de prendre seulement la place nécessaire
          //physics: const NeverScrollableScrollPhysics(), // Empêche cette ListView de défiler (le SingleChildScrollView s'en charge)
          itemCount: vm.structures.length,
          itemBuilder: (context, index) {
            final struct = vm.structures[index];

            return Container(
              // Le ListTile est plus adapté pour ce layout
              child: ListTile(
                onTap: (){
                  Navigator.pushNamed(
                    context, '/detaille_structure',
                    arguments: {
                      'id': struct,
                     // 'numero': context.read<AppState>().numeroUtilisateur,
                    },
                  );
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                leading: CircleAvatar(
                  radius: 35, // Augmenté pour un meilleur aspect
                  backgroundImage:
                    (vm.structures[index].logo != null && vm.structures[index].logo!.isNotEmpty)
                    ? NetworkImage(
                  //"$_baseUrlCover${s.id}/logos/${s.logo}"
                    "${AppState.baseUrlCover}${vm.structures[index].id}/logos/${vm.structures[index].logo}"
                )
                    : null,
                onBackgroundImageError: (e, _) =>
                    debugPrint('Logo erreur : $e'),
                child: (vm.structures[index].logo == null || vm.structures[index].logo!.isEmpty)
                    ? const Icon(Icons.business, color: Colors.grey)
                    : null,
                ),
                title: Text(
                  vm.structures[index].name??'',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${vm.structures[index].bookNumber} livres",
                  style: TextStyle(fontSize: 13),
                ),
                trailing: Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    color: vm.structures[index].isAdhere ? Colors.black45 : Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      vm.structures[index].isAdhere ? "Adhéré" : "S'adhérer", // Texte dynamique
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
                    onPressed: vm.chargerStructures,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/lecteur_audio_view_model.dart';

class LecteurAudioView extends StatefulWidget {
  const LecteurAudioView({super.key});

  @override
  State<LecteurAudioView> createState() => _LecteurAudioViewState();
}

class _LecteurAudioViewState extends State<LecteurAudioView>
    with WidgetsBindingObserver {

  String _chemin    = '';
  String _titre     = '';
  String _auteur    = '';
  bool   _isInitialized = false;

  // Vitesses disponibles
  final List<double> _vitesses = [0.5, 0.75, 1.0, 1.25,];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _chemin = args['chemin']?.toString()    ?? '';
        _titre  = args['titre']?.toString()     ?? 'Livre audio';
        _auteur = args['nom_auteur']?.toString() ?? '';
      }
      _isInitialized = true;

      Future.microtask(() {
        if (mounted) {
          context.read<LecteurAudioViewModel>()
              .initialiser(_chemin, _titre, _auteur);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LecteurAudioViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor : Colors.transparent,
            elevation       : 0,
            centerTitle     : true,
            title: const Text('Lecteur Audio',
                style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: vm.isLoading
              ? _buildChargement()
              : vm.errorMessage.isNotEmpty
              ? _buildErreur(vm)
              : _buildContenu(vm),
        );
      },
    );
  }

  // ── Chargement ───────────────────────────────────────────────────────
  Widget _buildChargement() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green),
          SizedBox(height: 16),
          Text('Chargement du fichier audio...',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ── Erreur ───────────────────────────────────────────────────────────
  Widget _buildErreur(LecteurAudioViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(vm.errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  vm.initialiser(_chemin, _titre, _auteur),
              icon : const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contenu principal ────────────────────────────────────────────────
  Widget _buildContenu(LecteurAudioViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          // ── Couverture ─────────────────────────────────────────────
          _buildCouverture(vm),

          // ── Titre + auteur ─────────────────────────────────────────
          Column(children: [
            Text(
              vm.titre.isNotEmpty ? vm.titre : _titre,
              maxLines   : 2,
              overflow   : TextOverflow.ellipsis,
              textAlign  : TextAlign.center,
              style: const TextStyle(
                color     : Colors.white,
                fontSize  : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              vm.auteur.isNotEmpty ? vm.auteur : _auteur,
              style: const TextStyle(
                  color: Colors.green, fontSize: 14),
            ),
          ]),

          // ── Barre de progression ───────────────────────────────────
          _buildBarreProgression(vm),

          // ── Contrôles ─────────────────────────────────────────────
          _buildControles(vm),

          // ── Vitesse de lecture ─────────────────────────────────────
          _buildVitesse(vm),
        ],
      ),
    );
  }

  // ── Couverture animée ────────────────────────────────────────────────
  Widget _buildCouverture(LecteurAudioViewModel vm) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width : vm.isPlaying ? 240 : 200,
      height: vm.isPlaying ? 240 : 200,
      decoration: BoxDecoration(
        shape     : BoxShape.circle,
        boxShadow : [
          BoxShadow(
            color     : Colors.green.withOpacity(vm.isPlaying ? 0.4 : 0.1),
            blurRadius: vm.isPlaying ? 40 : 10,
            spreadRadius: vm.isPlaying ? 10 : 2,
          ),
        ],
        image: const DecorationImage(

          image: AssetImage('assets/images/img_wait_cover_book.png'), fit  : BoxFit.cover,),
      ),
    );
  }

  // ── Barre de progression avec buffering ──────────────────────────────
  Widget _buildBarreProgression(LecteurAudioViewModel vm) {
    return Column(children: [
      // Barre buffering + progression superposées
      Stack(
        alignment: Alignment.center, // Aligne verticalement au centre le buffer et le slider
        children: [
          // 1. Buffering (Barre de mise en cache)
          Padding(
            // On ajoute une marge horizontale de ~20 pour s'aligner sur le track du Slider
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: vm.duree.inSeconds > 0
                    ? (vm.buffered.inSeconds / vm.duree.inSeconds).clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2D5A27)), // Vert sombre pour le cache
                minHeight: 4, // Doit correspondre au trackHeight du SliderTheme
              ),
            ),
          ),

          // 2. Slider de position
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4, // Même hauteur que le LinearProgressIndicator
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16),
              activeTrackColor: Colors.green,
              // IMPORTANT : Mettre le rail inactif en transparent pour voir le buffering dessous
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.green,
              overlayColor: Colors.green.withOpacity(0.2),
            ),
            child: Slider(
              value: vm.progression.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              onChanged: (v) => vm.seekToSlider(v),
            ),
          ),
        ],
      ),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(vm.formaterDuree(vm.position),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
            Text(vm.formaterDuree(vm.duree),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    ]);
  }

  // ── Contrôles ────────────────────────────────────────────────────────
  Widget _buildControles(LecteurAudioViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [

        // ─ Reculer 10s ──────────────────────────────────────────────
        _boutonIcone(
          icone   : Icons.replay_10,
          taille  : 36,
          onTap   : vm.reculer,
          couleur : Colors.white70,
        ),

        // ─ Play / Pause ──────────────────────────────────────────────
        GestureDetector(
          onTap: vm.togglePlay,
          child: Container(
            width : 72, height: 72,
            decoration: BoxDecoration(
              color     : Colors.green,
              shape     : BoxShape.circle,
              boxShadow : [
                BoxShadow(
                  color     : Colors.green.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              vm.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size : 40,
            ),
          ),
        ),

        // ─ Avancer 10s ──────────────────────────────────────────────
        _boutonIcone(
          icone   : Icons.forward_10,
          taille  : 36,
          onTap   : vm.avancer,
          couleur : Colors.white70,
        ),
      ],
    );
  }

  // ── Sélecteur de vitesse ─────────────────────────────────────────────
  Widget _buildVitesse(LecteurAudioViewModel vm) {
    return Column(children: [
      const Text('Vitesse',
          style: TextStyle(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _vitesses.map((v) {
          final bool actif = vm.vitesse == v;
          return GestureDetector(
            onTap: () => vm.changerVitesse(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin  : const EdgeInsets.symmetric(horizontal: 4),
              padding : const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color       : actif ? Colors.green : Colors.white12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${v}x',
                style: TextStyle(
                  color     : actif ? Colors.white : Colors.white54,
                  fontSize  : 12,
                  fontWeight: actif
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  // ── Bouton icône générique ───────────────────────────────────────────
  Widget _boutonIcone({
    required IconData  icone,
    required double    taille,
    required VoidCallback onTap,
    Color couleur = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icone, color: couleur, size: taille),
      ),
    );
  }
}

enum ActionAudio { pause, play,rewind,forward  }

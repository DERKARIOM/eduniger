import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';

import '../view_model/lecteur_pdf_view_model.dart';

class LecteurPdfView extends StatefulWidget {
  const LecteurPdfView({super.key});

  @override
  State<LecteurPdfView> createState() => _LecteurPdfViewState();
}

class _LecteurPdfViewState extends State<LecteurPdfView> {
  PDFViewController? _pdfController;
  bool _isInitialized = false;
  String _chemin = '';
  String _titre  = '';

  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _chemin = args['chemin']?.toString() ?? '';
        _titre  = args['titre']?.toString()  ?? 'Document';
      }
      _isInitialized = true;
      Future.microtask(() {
        context.read<LecteurPdfViewModel>()
            .initialiser(_chemin, _titre);
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LecteurPdfViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF2C2C2C),

          // ── AppBar avec progression ────────────────────────────────
          appBar: vm.afficherBarre
              ? AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            elevation      : 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vm.titre,
                    maxLines : 1,
                    overflow : TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),
                Text(
                  vm.totalPages > 0
                      ? 'Page ${vm.pageCourante} / ${vm.totalPages}'
                      : 'Chargement...',
                  style: const TextStyle(
                      color: Colors.green, fontSize: 11),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                value          : vm.progression,
                backgroundColor: Colors.white12,
                valueColor     : const AlwaysStoppedAnimation<Color>(
                    Colors.green),
              ),
            ),
            actions: [
              // ─ Aller à une page ────────────────────────────
              IconButton(
                icon    : const Icon(Icons.find_in_page,
                    color: Colors.white),
                tooltip : 'Aller à la page',
                onPressed: () => _dialogAllerAPage(vm),
              ),
            ],
          )
              : null,

          // ── Corps ─────────────────────────────────────────────────
          body: GestureDetector(
            // Tap → afficher/masquer la barre
            onTap: vm.toggleBarre,
            child: _buildCorps(vm),
          ),

          // ── Navigation bas de page ─────────────────────────────────
          bottomNavigationBar: vm.afficherBarre
              ? _buildNavigation(vm)
              : null,
        );
      },
    );
  }

  // ── Corps ────────────────────────────────────────────────────────────
  Widget _buildCorps(LecteurPdfViewModel vm) {
    if (vm.errorMessage.isNotEmpty) return _buildErreur(vm);

    // Vérifier que le fichier existe
    if (_chemin.isEmpty || !File(_chemin).existsSync()) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_present, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Fichier introuvable.',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return Stack(children: [

      // ── PDF ──────────────────────────────────────────────────────
      PDFView(
        filePath         : _chemin,
        enableSwipe      : true,
        swipeHorizontal  : false,
        autoSpacing      : true,
        pageFling        : true,
        fitPolicy        : FitPolicy.WIDTH,
        defaultPage      : 0,
        preventLinkNavigation: false,

        onRender: (pages) {
          if (pages != null) {
            context.read<LecteurPdfViewModel>()
                .onDocumentLoaded(pages);
          }
        },

        onViewCreated: (controller) {
          _pdfController = controller;
        },

        onPageChanged: (page, total) {
          if (page != null && total != null) {
            context.read<LecteurPdfViewModel>()
                .onPageChanged(page + 1, total);
          }
        },

        onError: (error) {
          context.read<LecteurPdfViewModel>()
              .onError(error.toString());
        },

        onPageError: (page, error) {
          debugPrint("Erreur page $page : $error");
        },
      ),

      // ── Indicateur de chargement ─────────────────────────────────
      if (vm.isLoading)
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 12),
              Text('Ouverture du document...',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
    ]);
  }

  // ── Navigation bas ───────────────────────────────────────────────────
  Widget _buildNavigation(LecteurPdfViewModel vm) {
    return Container(
      height: 60,
      color : const Color(0xFF1A1A1A),
      child : Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          // ─ Page précédente ──────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: Colors.white),
            onPressed: vm.pageCourante > 1
                ? () => _allerAPage(vm.pageCourante - 2)
                : null,
          ),

          // ─ Numéro de page (cliquable) ───────────────────────────
          GestureDetector(
            onTap: () => _dialogAllerAPage(vm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color       : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.green.withOpacity(0.5)),
              ),
              child: Text(
                '${vm.pageCourante} / ${vm.totalPages}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ─ Page suivante ────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: Colors.white),
            onPressed: vm.pageCourante < vm.totalPages
                ? () => _allerAPage(vm.pageCourante)
                : null,
          ),
        ],
      ),
    );
  }

  // ── Dialog : aller à une page ────────────────────────────────────────
  Future<void> _dialogAllerAPage(LecteurPdfViewModel vm) async {
    _pageController.clear();
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Aller à la page (1 - ${vm.totalPages})',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        content: TextField(
          controller  : _pageController,
          keyboardType: TextInputType.number,
          autofocus   : true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText     : 'Numéro de page',
            hintStyle    : TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final int? page = int.tryParse(_pageController.text);
              if (page != null &&
                  page >= 1 && page <= vm.totalPages) {
                Navigator.pop(context, page);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green),
            child: const Text('Aller'),
          ),
        ],
      ),
    );

    if (result != null) _allerAPage(result - 1);
  }

  void _allerAPage(int pageIndex) {
    _pdfController?.setPage(pageIndex);
  }

  // ── Erreur ───────────────────────────────────────────────────────────
  Widget _buildErreur(LecteurPdfViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf,
                size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Impossible d\'ouvrir le document.\n${vm.errorMessage}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon : const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
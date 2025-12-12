import 'package:eduniger/utils/constants.dart';
import 'package:eduniger/utils/helper.dart';
import 'package:eduniger/widgets/videos_grid.dart';
import 'package:flutter/material.dart';
import 'package:eduniger/services/video_api.dart';
import 'package:eduniger/models/Video.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Video> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Charger les vidéos UNE SEULE FOIS au démarrage
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      final result = await getVideosFromApi();
      setState(() {
        videos = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Optionnel: afficher un message d'erreur
      print('Erreur lors du chargement des vidéos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "OrangeValleyCaa",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: backgroundColor,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : videos.isEmpty
            ? Center(child: Text('Aucune vidéo disponible'))
            : VideosGrid(videos: videos),
      ),
    );
  }
}
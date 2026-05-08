import 'package:eduniger/localDataBase/sqlflitEduniger.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ══════════════════════════════════════════════════════════════════════
// AUDIO HANDLER — lecture en arrière-plan (notification système)
// ══════════════════════════════════════════════════════════════════════
class EduNigerAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  EduNigerAudioHandler() {
    // Écouter les changements d'état du player → mettre à jour la notification
    _player.playbackEventStream.listen(_broadcast);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
      }
    });
  }

  // ── Charger un fichier audio ────────────────────────────────────────
  Future<void> charger(String chemin, String titre, String auteur) async {
    // Mettre à jour les métadonnées affichées dans la notification
    mediaItem.add(MediaItem(
      id          : chemin,
      title       : titre,
      artist      : auteur,
      album       : 'EduNiger',
      displayTitle: titre,
    ));
    await _player.setFilePath(chemin);
  }

  // ── Contrôles (appelés par la notification et par l'UI) ─────────────
  @override Future<void> play()  => _player.play();
  @override Future<void> pause() => _player.pause();
  @override Future<void> stop()  async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> fastForward() =>
      _player.seek(_player.position + const Duration(seconds: 10));

  @override
  Future<void> rewind() =>
      _player.seek(_player.position - const Duration(seconds: 10));

  // ── Exposer le player pour les streams ─────────────────────────────
  AudioPlayer get player => _player;

  // ── Synchroniser l'état vers la notification ────────────────────────
  void _broadcast(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.rewind,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.fastForward,
        MediaControl.stop,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle    : AudioProcessingState.idle,
        ProcessingState.loading : AudioProcessingState.loading,
        ProcessingState.buffering:AudioProcessingState.buffering,
        ProcessingState.ready   : AudioProcessingState.ready,
        ProcessingState.completed:AudioProcessingState.completed,
      }[_player.processingState]!,
      playing  : playing,
      updatePosition : _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed    : _player.speed,
      queueIndex: 0,
    ));
  }
}

// ══════════════════════════════════════════════════════════════════════
// VIEW MODEL
// ══════════════════════════════════════════════════════════════════════
class LecteurAudioViewModel extends ChangeNotifier {

  // ── Handler audio (singleton) ─────────────────────────────────────
  static EduNigerAudioHandler? _handler;

  EduNigerAudioHandler get handler {
    _handler ??= EduNigerAudioHandler();
    return _handler!;
  }

  AudioPlayer get _player => handler.player;

  // ── État ──────────────────────────────────────────────────────────
  String  _titre         = '';
  String  _auteur        = '';
  String  _chemin        = '';
  bool    _isLoading     = false;
  bool    _isPlaying     = false;
  bool    _isInitialise  = false;
  String  _errorMessage  = '';
  Duration _position     = Duration.zero;
  Duration _duree        = Duration.zero;
  Duration _buffered     = Duration.zero;
  double   _vitesse      = 1.0;

  // ── Getters ───────────────────────────────────────────────────────
  String   get titre         => _titre;
  String   get auteur        => _auteur;
  bool     get isLoading     => _isLoading;
  bool     get isPlaying     => _isPlaying;
  bool     get isInitialise  => _isInitialise;
  String   get errorMessage  => _errorMessage;
  Duration get position      => _position;
  Duration get duree         => _duree;
  Duration get buffered      => _buffered;
  double   get vitesse       => _vitesse;

  // ── Progression 0.0 → 1.0 ─────────────────────────────────────────
  double get progression =>
      _duree.inSeconds > 0
          ? (_position.inSeconds / _duree.inSeconds).clamp(0.0, 1.0)
          : 0.0;

  // ── Souscriptions ─────────────────────────────────────────────────
  StreamSubscription? _positionSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _dureeSub;
  StreamSubscription? _bufferedSub;
  StreamSubscription? _processSub;

  // ══════════════════════════════════════════════════════════════════
  // INITIALISATION
  // ══════════════════════════════════════════════════════════════════
  Future<void> initialiser(
      String chemin, String titre, String auteur) async {
    // Déjà initialisé avec le même fichier → reprendre simplement
    if (_chemin == chemin && _isInitialise) return;

    _isLoading    = true;
    _errorMessage = '';
    _chemin       = chemin;
    _titre        = titre;
    _auteur       = auteur;
    notifyListeners();

    try {
      // Enregistrer le service audio (une seule fois)
      if (_handler != null) return;
      if (_handler == null) {
        _handler = await AudioService.init(
          builder: () => EduNigerAudioHandler(),
          config: const AudioServiceConfig(
            androidNotificationChannelId  : 'com.eduniger.audio',
            androidNotificationChannelName: 'EduNiger Audio',
            androidNotificationOngoing    : true,
            androidStopForegroundOnPause  : true,
            notificationColor             : Color(0xFF4CAF50),
          ),
        );
      }

      await handler.charger(chemin, titre, auteur);

      // Écouter les streams du player
      _annulerSouscriptions();
      _positionSub = _player.positionStream.listen((p) {
        _position = p;
        notifyListeners();
      });
      _dureeSub = _player.durationStream.listen((d) {
        _duree = d ?? Duration.zero;
        notifyListeners();
      });
      _bufferedSub = _player.bufferedPositionStream.listen((b) {
        _buffered = b;
        notifyListeners();
      });
      _playingSub = _player.playingStream.listen((playing) {
        _isPlaying = playing;
        notifyListeners();
      });
      _processSub = _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _isPlaying = false;
          _position  = Duration.zero;
          notifyListeners();
        }
      });

      _isInitialise = true;

    } catch (e) {
      _errorMessage = 'Impossible de charger le fichier audio : $e';
      debugPrint("❌ Audio init : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // CONTRÔLES
  // ══════════════════════════════════════════════════════════════════
  Future<void> togglePlay() async {
    if (_isPlaying) {
      await handler.pause();
    } else {
      await handler.play();
    }
  }

  Future<void> avancer() async {
    await handler.fastForward(); // +10s
  }

  Future<void> reculer() async {
    await handler.rewind(); // -10s
  }

  Future<void> seekTo(Duration position) async {
    await handler.seek(position);
  }

  Future<void> seekToSlider(double value) async {
    final Duration cible = Duration(
      seconds: (value * _duree.inSeconds).round(),
    );
    await seekTo(cible);
  }

  Future<void> changerVitesse(double vitesse) async {
    _vitesse = vitesse;
    await _player.setSpeed(vitesse);
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════
  // UTILITAIRES
  // ══════════════════════════════════════════════════════════════════
  String formaterDuree(Duration d) {
    final String h = d.inHours > 0
        ? '${d.inHours.toString().padLeft(2, '0')}:'
        : '';
    final String m =
    d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String s =
    d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h$m:$s';
  }

  void _annulerSouscriptions() {
    _positionSub?.cancel();
    _dureeSub?.cancel();
    _bufferedSub?.cancel();
    _playingSub?.cancel();
    _processSub?.cancel();
  }

  @override
  void dispose() {
    _annulerSouscriptions();
    // On ne dispose PAS le handler : il doit rester actif en arrière-plan
    super.dispose();
  }
}
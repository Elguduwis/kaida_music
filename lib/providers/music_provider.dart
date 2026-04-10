import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/song_model.dart';
import '../services/music_library_service.dart';
import '../services/audio_player_service.dart';

class MusicProvider extends ChangeNotifier {
  final MusicLibraryService _libraryService = MusicLibraryService();
  AudioPlayerHandler? _audioHandler;

  List<SongModelExt> _allSongs = [];
  List<SongModelExt> _currentQueue = [];
  SongModelExt? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;
  bool _shuffleEnabled = false;

  // Getters
  List<SongModelExt> get allSongs => _allSongs;
  List<SongModelExt> get currentQueue => _currentQueue;
  SongModelExt? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioServiceRepeatMode get repeatMode => _repeatMode;
  bool get shuffleEnabled => _shuffleEnabled;
  AudioPlayerHandler? get audioHandler => _audioHandler;

  MusicProvider() {
    _initAudioHandler();
  }

  Future<void> _initAudioHandler() async {
    _audioHandler = await initAudioService();
    _audioHandler!.playbackState.listen((state) {
      _isPlaying = state.playing;
      _position = state.position;
      _repeatMode = state.repeatMode;
      _shuffleEnabled = state.shuffleMode == AudioServiceShuffleMode.all;
      notifyListeners();
    });
    _audioHandler!.mediaItem.listen((item) {
      if (item != null) {
        // Find matching song in loaded list
        final found = _allSongs.firstWhere(
          (s) => s.song.id.toString() == item.id,
          orElse: () => SongModelExt.fromMediaItem(item),
        );
        _currentSong = found;
        _duration = item.duration ?? Duration.zero;
        notifyListeners();
      }
    });
    // Use the streams exposed by our custom handler (not .player)
    _audioHandler!.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _audioHandler!.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> loadSongs() async {
    if (await _libraryService.requestPermissions()) {
      _allSongs = await _libraryService.getAllSongs();
      notifyListeners();
    }
  }

  Future<void> playSong(SongModelExt song, {List<SongModelExt>? queue}) async {
    final queueToPlay = queue ?? _allSongs;
    final startIndex = queueToPlay.indexWhere((s) => s.song.id == song.song.id);
    _currentQueue = queueToPlay;
    await _audioHandler?.updatePlaylist(queueToPlay, startIndex: startIndex);
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_isPlaying) {
      await _audioHandler?.pause();
    } else {
      await _audioHandler?.play();
    }
  }

  Future<void> next() async {
    await _audioHandler?.skipToNext();
  }

  Future<void> previous() async {
    await _audioHandler?.skipToPrevious();
  }

  Future<void> seek(Duration position) async {
    await _audioHandler?.seek(position);
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    await _audioHandler?.setRepeatMode(mode);
    _repeatMode = mode;
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    final newMode = !_shuffleEnabled;
    await _audioHandler?.setShuffleMode(
      newMode ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
    _shuffleEnabled = newMode;
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _currentQueue.length) return;
    _currentQueue.removeAt(index);
    _audioHandler?.updatePlaylist(_currentQueue,
        startIndex: _audioHandler!.currentIndex ?? 0);
    notifyListeners();
  }
}

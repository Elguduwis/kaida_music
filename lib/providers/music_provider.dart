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
  bool _isLoading = false;
  String? _error;
  bool _audioServiceReady = false;

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
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get audioServiceReady => _audioServiceReady;

  MusicProvider() {
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    try {
      print('Initializing Audio Service...');
      _audioHandler = await initAudioService();
      _audioServiceReady = true;
      print('Audio Service initialized successfully');
      
      _audioHandler!.playbackState.listen((state) {
        _isPlaying = state.playing;
        _position = state.position;
        _repeatMode = state.repeatMode;
        _shuffleEnabled = state.shuffleMode == AudioServiceShuffleMode.all;
        notifyListeners();
      });
      
      _audioHandler!.mediaItem.listen((item) {
        if (item != null) {
          final found = _allSongs.firstWhere(
            (s) => s.song.id.toString() == item.id,
            orElse: () => SongModelExt.fromMediaItem(item),
          );
          _currentSong = found;
          _duration = item.duration ?? Duration.zero;
          notifyListeners();
        }
      });
      
      _audioHandler!.positionStream.listen((pos) {
        _position = pos;
        notifyListeners();
      });
      
      _audioHandler!.durationStream.listen((dur) {
        _duration = dur ?? Duration.zero;
        notifyListeners();
      });
      
      notifyListeners();
    } catch (e) {
      print('Error initializing audio service: $e');
      _error = 'Failed to initialize audio: $e';
      notifyListeners();
    }
  }

  Future<void> loadSongs() async {
    // Wait for audio service to be ready
    int retries = 0;
    while (!_audioServiceReady && retries < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
    }
    
    if (!_audioServiceReady) {
      _error = 'Audio service not ready';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading songs...');
      final hasPermission = await _libraryService.requestPermissions();
      if (!hasPermission) {
        _error = 'Storage permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _allSongs = await _libraryService.getAllSongs();
      print('Loaded ${_allSongs.length} songs');
      _error = null;
    } catch (e) {
      print('Error loading songs: $e');
      _error = 'Failed to load songs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playSong(SongModelExt song, {List<SongModelExt>? queue}) async {
    if (_audioHandler == null) return;
    
    final queueToPlay = queue ?? _allSongs;
    final startIndex = queueToPlay.indexWhere((s) => s.song.id == song.song.id);
    if (startIndex == -1) return;
    
    _currentQueue = queueToPlay;
    await _audioHandler!.updatePlaylist(queueToPlay, startIndex: startIndex);
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

  void refreshSongs() {
    loadSongs();
  }
}

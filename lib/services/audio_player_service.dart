import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

Future<AudioPlayerHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.kaida.music.channel.audio',
      androidNotificationChannelName: 'Kaida Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  // Expose streams for UI
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  int? get currentIndex => _player.currentIndex;
  List<AudioSource> get sequence => _player.sequence ?? [];

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.setAudioSource(_playlist);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _player.setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // Not used directly
  }

  Future<void> updatePlaylist(List<SongModelExt> songs, {int startIndex = 0}) async {
    final items = songs.map((s) {
      return AudioSource.uri(
        Uri.parse(s.uri),
        tag: MediaItem(
          id: s.song.id.toString(),
          title: s.displayName,
          artist: s.artist,
          album: s.album,
          artUri: s.artworkPath != null ? Uri.parse(s.artworkPath!) : null,
          duration: s.duration,
        ),
      );
    }).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: items),
      initialIndex: startIndex,
    );
    mediaItem.add(_player.sequence![startIndex].tag as MediaItem);
  }

  Future<void> playFromQueueIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    play();
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}

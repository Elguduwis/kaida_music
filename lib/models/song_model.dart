import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';

class SongModelExt {
  final SongModel song;
  final String displayName;
  final String artist;
  final String album;
  final String? artworkPath;
  final Duration duration;
  final String uri;

  SongModelExt({
    required this.song,
    required this.displayName,
    required this.artist,
    required this.album,
    this.artworkPath,
    required this.duration,
    required this.uri,
  });

  factory SongModelExt.fromSongModel(SongModel song) {
    return SongModelExt(
      song: song,
      displayName: song.displayNameWOExt,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      artworkPath: song.albumId != null
          ? "content://media/external/audio/albumart/${song.albumId}"
          : null,
      duration: Duration(milliseconds: song.duration ?? 0),
      uri: song.uri ?? '',
    );
  }

  /// Fallback factory from a MediaItem (used when the original SongModel is not found)
  factory SongModelExt.fromMediaItem(MediaItem item) {
    // Create a minimal SongModel stub with required fields
    final stubSong = SongModel(
      int.tryParse(item.id) ?? -1,
      item.title,
      item.artist,
      item.album,
      item.duration?.inMilliseconds,
      item.extras?['uri'] as String? ?? '',
    );
    return SongModelExt(
      song: stubSong,
      displayName: item.title,
      artist: item.artist ?? 'Unknown Artist',
      album: item.album ?? 'Unknown Album',
      artworkPath: item.artUri?.toString(),
      duration: item.duration ?? Duration.zero,
      uri: item.extras?['uri'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMediaItem() {
    return {
      'id': song.id.toString(),
      'title': displayName,
      'artist': artist,
      'album': album,
      'artUri': artworkPath,
      'duration': duration.inMilliseconds,
      'uri': uri,
    };
  }
}

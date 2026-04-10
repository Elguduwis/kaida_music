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

  /// Fallback for when the original SongModel is not available (e.g., from a MediaItem)
  factory SongModelExt.fromMediaItem(MediaItem item) {
    // Use a minimal placeholder SongModel (no manual constructor call)
    // We'll store the data directly in the wrapper; the 'song' field is just a stub.
    // However, to satisfy the type, we use the empty constructor provided by the library.
    final stub = SongModel({
      '_id': int.tryParse(item.id) ?? -1,
      'title': item.title,
      'artist': item.artist,
      'album': item.album,
      'duration': item.duration?.inMilliseconds,
      '_data': item.extras?['uri'] ?? '',
    });
    return SongModelExt(
      song: stub,
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

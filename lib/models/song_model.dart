import 'package:on_audio_query/on_audio_query.dart';

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

  // For queue items (used by audio_service)
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

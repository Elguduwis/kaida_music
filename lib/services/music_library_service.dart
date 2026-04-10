import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';

class MusicLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Use the plugin's built-in permission request method
  Future<bool> requestPermissions() async {
    try {
      // This is the official way to request permissions with on_audio_query
      final hasPermission = await _audioQuery.permissionsRequest();
      return hasPermission ?? false;
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  /// Alternative: check and request with retry
  Future<bool> checkAndRequestPermissions({bool retry = false}) async {
    try {
      final hasPermission = await _audioQuery.checkAndRequest(
        retryRequest: retry,
      );
      return hasPermission ?? false;
    } catch (e) {
      print('Check and request error: $e');
      return false;
    }
  }

  Future<List<SongModelExt>> getAllSongs() async {
    try {
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      return songs.map((s) => SongModelExt.fromSongModel(s)).toList();
    } catch (e) {
      print('Error getting songs: $e');
      return [];
    }
  }

  Future<List<ArtistModel>> getArtists() async {
    return await _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
  }

  Future<List<SongModelExt>> getSongsByArtist(int artistId) async {
    final List<SongModel> songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ARTIST_ID,
      artistId,
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
    );
    return songs.map((s) => SongModelExt.fromSongModel(s)).toList();
  }

  Future<List<String>> getFolderPaths() async {
    final List<dynamic> raw = await _audioQuery.queryAllPath();
    return raw.map((e) => (e as dynamic).path as String).toList();
  }

  Future<List<SongModelExt>> getSongsFromFolder(String path) async {
    final List<SongModel> songs = await _audioQuery.querySongs(
      path: path,
      sortType: SongSortType.TITLE,
      uriType: UriType.EXTERNAL,
    );
    return songs.map((s) => SongModelExt.fromSongModel(s)).toList();
  }

  Future<bool> renameSong(SongModelExt song, String newName) async => false;
  Future<bool> deleteSong(String uri) async => false;
}

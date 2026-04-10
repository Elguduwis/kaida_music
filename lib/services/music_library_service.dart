import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';

class MusicLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermissions() async {
    final storage = await Permission.storage.request();
    if (storage.isGranted) return true;
    final audio = await Permission.audio.request();
    return audio.isGranted;
  }

  Future<List<SongModelExt>> getAllSongs() async {
    final List<SongModel> songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    return songs.map((s) => SongModelExt.fromSongModel(s)).toList();
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

  // Return folder paths as strings (bypass FolderModel type issues)
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

  // Demo limitations
  Future<bool> renameSong(SongModelExt song, String newName) async => false;
  Future<bool> deleteSong(String uri) async => false;
}

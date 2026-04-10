import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';

class MusicLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermissions() async {
    print('=== MusicLibraryService: Requesting permissions ===');
    
    // Check current states
    final audioStatus = await Permission.audio.status;
    final storageStatus = await Permission.storage.status;
    
    print('Current audio status: $audioStatus');
    print('Current storage status: $storageStatus');
    
    // If already granted, return true
    if (audioStatus.isGranted || storageStatus.isGranted) {
      print('Permission already granted');
      return true;
    }
    
    // Try audio permission
    print('Requesting audio permission...');
    final audioResult = await Permission.audio.request();
    print('Audio request result: $audioResult');
    if (audioResult.isGranted) return true;
    
    // Try storage permission as fallback
    print('Requesting storage permission...');
    final storageResult = await Permission.storage.request();
    print('Storage request result: $storageResult');
    return storageResult.isGranted;
  }

  Future<List<SongModelExt>> getAllSongs() async {
    print('=== Getting all songs ===');
    try {
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      print('Found ${songs.length} songs');
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

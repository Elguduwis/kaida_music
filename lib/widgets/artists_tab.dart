import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/music_library_service.dart';
import '../models/song_model.dart';
import 'song_list_tile.dart';

class ArtistsTab extends StatefulWidget {
  const ArtistsTab({super.key});

  @override
  State<ArtistsTab> createState() => _ArtistsTabState();
}

class _ArtistsTabState extends State<ArtistsTab> {
  final MusicLibraryService _service = MusicLibraryService();
  List<ArtistModel> _artists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    if (await _service.requestPermissions()) {
      final artists = await _service.getArtists();
      setState(() {
        _artists = artists;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: _artists.length,
      itemBuilder: (context, index) {
        final artist = _artists[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(artist.artist),
          subtitle: Text('${artist.numberOfTracks} tracks'),
          onTap: () => _showArtistSongs(artist),
        );
      },
    );
  }

  void _showArtistSongs(ArtistModel artist) async {
    final songs = await _service.getSongsByArtist(artist.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(artist.artist)),
          body: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (ctx, i) {
              return SongListTile(
                song: songs[i],
                onTap: () {
                  context.read<MusicProvider>().playSong(songs[i], queue: songs);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

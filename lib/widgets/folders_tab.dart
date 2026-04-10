import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/music_library_service.dart';
import '../providers/music_provider.dart';
import '../models/song_model.dart';
import 'song_list_tile.dart';

class FoldersTab extends StatefulWidget {
  const FoldersTab({super.key});

  @override
  State<FoldersTab> createState() => _FoldersTabState();
}

class _FoldersTabState extends State<FoldersTab> {
  final MusicLibraryService _service = MusicLibraryService();
  List<String> _folderPaths = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    if (await _service.requestPermissions()) {
      final paths = await _service.getFolderPaths();
      setState(() {
        _folderPaths = paths;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: _folderPaths.length,
      itemBuilder: (context, index) {
        final path = _folderPaths[index];
        final name = _service.getFolderName(path);
        return FutureBuilder<int>(
          future: _service.countSongsInFolder(path),
          builder: (ctx, snapshot) {
            final count = snapshot.data ?? 0;
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(name),
              subtitle: Text('$count songs'),
              onTap: () => _showFolderSongs(path),
            );
          },
        );
      },
    );
  }

  void _showFolderSongs(String folderPath) async {
    final songs = await _service.getSongsFromFolder(folderPath);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(_service.getFolderName(folderPath))),
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

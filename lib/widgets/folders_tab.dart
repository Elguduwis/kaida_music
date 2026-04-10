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
  List<FolderModel> _folders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    if (await _service.requestPermissions()) {
      final folders = await _service.getFolders();
      setState(() {
        _folders = folders;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: _folders.length,
      itemBuilder: (context, index) {
        final folder = _folders[index];
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(folder.folderName),
          subtitle: Text('${folder.numOfSongs} songs'),
          onTap: () => _showFolderSongs(folder),
        );
      },
    );
  }

  void _showFolderSongs(FolderModel folder) async {
    final songs = await _service.getSongsFromFolder(folder.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(folder.folderName)),
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

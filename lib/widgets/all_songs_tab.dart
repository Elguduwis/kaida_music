import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song_model.dart';
import 'song_list_tile.dart';

class AllSongsTab extends StatelessWidget {
  const AllSongsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final songs = provider.allSongs;
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return SongListTile(
          song: songs[index],
          onTap: () => provider.playSong(songs[index]),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song_model.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Playing Queue')),
      body: ReorderableListView.builder(
        itemCount: provider.currentQueue.length,
        onReorder: (oldIndex, newIndex) {
          // Reorder logic could be added here
        },
        itemBuilder: (context, index) {
          final song = provider.currentQueue[index];
          final isCurrent = provider.currentSong?.song.id == song.song.id;
          return ListTile(
            key: ValueKey(song.song.id),
            leading: Icon(
              isCurrent ? Icons.play_arrow : Icons.music_note,
              color: isCurrent ? Colors.red : null,
            ),
            title: Text(
              song.displayName,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Colors.red : null,
              ),
            ),
            subtitle: Text(song.artist),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                provider.removeFromQueue(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed ${song.displayName} from queue')),
                );
              },
            ),
            onTap: () {
              provider.playSong(song, queue: provider.currentQueue);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

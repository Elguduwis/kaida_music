import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/song_model.dart';

class SongListTile extends StatelessWidget {
  final SongModelExt song;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onMoreTap?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: song.artworkPath != null
            ? Image.network(
                song.artworkPath!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
              )
            : const Icon(Icons.music_note, size: 48),
        title: Text(song.displayName),
        subtitle: Text(song.artist),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptions(context),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                // Show rename dialog (demo)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rename feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Details'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(song.displayName),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Artist: ${song.artist}'),
                        Text('Album: ${song.album}'),
                        Text('Duration: ${song.duration}'),
                        Text('Path: ${song.uri}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

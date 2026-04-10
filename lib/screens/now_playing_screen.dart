import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import '../providers/music_provider.dart';
import 'queue_screen.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QueueScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE53935), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black12,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: provider.isPlaying ? 1 : 0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 6.28318,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: song.artworkPath != null
                        ? DecorationImage(
                            image: NetworkImage(song.artworkPath!),
                            fit: BoxFit.cover,
                            onError: (_, __) => const Icon(Icons.album, size: 150),
                          )
                        : null,
                  ),
                  child: song.artworkPath == null
                      ? const Icon(Icons.album, size: 150, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              song.displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              song.artist,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    _formatDuration(provider.position),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Expanded(
                    child: Slider(
                      value: provider.position.inMilliseconds.toDouble(),
                      max: provider.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        provider.seek(Duration(milliseconds: value.toInt()));
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    ),
                  ),
                  Text(
                    _formatDuration(provider.duration),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    provider.shuffleEnabled ? Icons.shuffle : Icons.shuffle_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: provider.toggleShuffle,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white, size: 48),
                  onPressed: provider.previous,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      provider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 48,
                    ),
                    onPressed: provider.playPause,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 48),
                  onPressed: provider.next,
                ),
                IconButton(
                  icon: Icon(
                    _repeatIcon(provider.repeatMode),
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => _cycleRepeatMode(context),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  IconData _repeatIcon(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.one:
        return Icons.repeat_one;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        return Icons.repeat;
      default:
        return Icons.repeat_outlined;
    }
  }

  void _cycleRepeatMode(BuildContext context) {
    final provider = context.read<MusicProvider>();
    final current = provider.repeatMode;
    switch (current) {
      case AudioServiceRepeatMode.none:
        provider.setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        provider.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case AudioServiceRepeatMode.one:
        provider.setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
  }
}

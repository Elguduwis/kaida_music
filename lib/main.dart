import 'package:flutter/material.dart';

void main() {
  runApp(const KaidaMusicApp());
}

class KaidaMusicApp extends StatelessWidget {
  const KaidaMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaida Music',
      theme: ThemeData(
        primaryColor: const Color(0xFF7351FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7351FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatelessWidget {
  const MusicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaida Music'),
        backgroundColor: const Color(0xFF7351FF),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 80,
              color: const Color(0xFF7351FF),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Kaida Music',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your African rhythm, anywhere.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player coming soon!')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7351FF),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

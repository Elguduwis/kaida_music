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
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Kaida Music',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7351FF),
            ),
          ),
        ),
      ),
    );
  }
}

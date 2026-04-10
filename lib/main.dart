import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/music_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const KaidaMusicApp());
}

class KaidaMusicApp extends StatelessWidget {
  const KaidaMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicProvider(),
      child: MaterialApp(
        title: 'Kaida Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const PermissionGate(),
      ),
    );
  }
}

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _isLoading = true;
  bool _hasPermission = false;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    // Check all relevant permission states
    final audioStatus = await Permission.audio.status;
    final storageStatus = await Permission.storage.status;
    final mediaStatus = await Permission.mediaLibrary.status;
    
    _debugInfo = '''
Audio: $audioStatus
Storage: $storageStatus
Media: $mediaStatus
    ''';

    print('Permission Statuses:');
    print('Audio: $audioStatus');
    print('Storage: $storageStatus');
    print('Media: $mediaStatus');

    // Try multiple permission approaches
    bool granted = false;
    
    // Try audio first
    if (audioStatus.isGranted) {
      granted = true;
    } else {
      final audioResult = await Permission.audio.request();
      print('Audio request result: $audioResult');
      if (audioResult.isGranted) granted = true;
    }
    
    // If audio didn't work, try storage
    if (!granted) {
      final storageResult = await Permission.storage.request();
      print('Storage request result: $storageResult');
      if (storageResult.isGranted) granted = true;
    }
    
    // Last resort: try mediaLibrary
    if (!granted) {
      final mediaResult = await Permission.mediaLibrary.request();
      print('Media request result: $mediaResult');
      if (mediaResult.isGranted) granted = true;
    }

    setState(() {
      _hasPermission = granted;
      _isLoading = false;
    });

    if (granted) {
      _loadMusic();
    } else {
      print('All permission requests denied');
    }
  }

  void _loadMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Checking permissions...\n$_debugInfo',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_off, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'Permission Status',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _debugInfo,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _checkAndRequestPermissions,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Open App Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}

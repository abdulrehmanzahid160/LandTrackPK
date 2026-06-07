import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LandTrackPKApp());
}

class LandTrackPKApp extends StatelessWidget {
  const LandTrackPKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LandTrack PK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}

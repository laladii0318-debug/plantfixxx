import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const PlantFixApp());
}

class PlantFixApp extends StatelessWidget {
  const PlantFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlantFix',
      home: const SplashScreen(),
    );
  }
}
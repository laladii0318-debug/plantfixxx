
import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'session_service.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
void initState() {
super.initState();

Timer(const Duration(seconds: 3), () {
_checkSession();
});
}

Future<void> _checkSession() async {
if (!mounted) return;

final isLoggedIn = await SessionService.isLoggedIn();

if (!mounted) return;

if (isLoggedIn) {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(),
),
);
} else {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const OnboardingScreen(),
),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.eco,
size: 100,
color: Colors.green,
),

const SizedBox(height: 20),

const Text(
'PlantFix',
style: TextStyle(
fontSize: 36,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
'Your Crop Doctor',
style: TextStyle(
fontSize: 18,
color: Colors.grey.shade600,
),
),
],
),
),
);
}
}


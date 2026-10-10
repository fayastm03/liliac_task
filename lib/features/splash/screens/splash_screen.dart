import 'dart:async';

import 'package:flutter/material.dart';

import '../../onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF72C5BC), Color(0xFF4AA69D), Color(0xFF318A82)],
          ),
        ),
        child: const Center(
          child: Text(
            'Expenzia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
        ),
      ),
    );
  }
}

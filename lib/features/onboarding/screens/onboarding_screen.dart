import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liliac/shared/widgets/app_bottom_navigation.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const Color _teal = Color(0xFF438883);
  static const Color _mint = Color(0xFFEDF8F6);

  // Original Figma illustration frame width.
  static const double _designWidth = 414;

  void _getStarted(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppBottomNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = width / _designWidth;
          final illustrationHeight = 600 * scale;

          return Column(
            children: [
              // Illustration section
              SizedBox(
                width: width,
                height: illustrationHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Mint background with circular outlines
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: illustrationHeight,
                      child: Image.asset(
                        'assets/images/onboarding_background.png',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(color: _mint);
                        },
                      ),
                    ),

                    // Character
                    Positioned(
                      top: 127 * scale,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/onboarding_character.png',
                        width: width,
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 120,
                            color: _teal,
                          );
                        },
                      ),
                    ),

                    // Floating Coin
                    Positioned(
                      left: 50 * scale,
                      top: 145 * scale,
                      width: 88 * scale,
                      height: 88 * scale,
                      child: Transform.rotate(
                        angle: -22 * math.pi / 180,
                        child: Image.asset(
                          'assets/images/Coint.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Floating Donut Chart
                    Positioned(
                      left: 269 * scale,
                      top: 202 * scale,
                      width: 80 * scale,
                      height: 80 * scale,
                      child: Image.asset(
                        'assets/images/Donut.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom content section
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(),
                        const Text(
                          'Spend Smarter\nSave More',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _teal,
                            fontSize: 36,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF63B5AF), Color(0xFF438883)],
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: _teal.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _getStarted(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

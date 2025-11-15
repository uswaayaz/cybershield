

import 'dart:async';
import 'package:flutter/material.dart';
import '../Auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineFade;

  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Logo animation (0.0 - 0.5 of timeline)
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Tagline animation (0.4 - 0.7 of timeline)
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Footer + loader (0.6 - 1.0 of timeline)
    _footerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(

          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFF154688)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  'assets/bg_logo.png',
                  height: 200,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tagline
            SlideTransition(
              position: _taglineSlide,
              child: FadeTransition(
                opacity: _taglineFade,
                child: const Text(
                  'REPORT • SECURE • PROTECT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF154688),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Loader + footer
            FadeTransition(
              opacity: _footerFade,
              child: Column(
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF154688)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 60),
                  Text(
                    'Project by CUI SWL',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF154688),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/starfield_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _starSpeed = 0.5;
  double _opacityTitle = 0.0;
  double _opacitySubtitle = 0.0;
  double _scale = 1.1; // Slight zoom out effect

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Start crawl
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _scale = 1.0;
      });
    });

    // 1. Fade in Title
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _opacityTitle = 1.0);

    // 2. Fade in Subtitle
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _opacitySubtitle = 1.0);

    // 3. Hold for reading
    await Future.delayed(const Duration(seconds: 3));
    
    // 4. Hyperspace & Fade Out Text
    if (!mounted) return;
    setState(() {
       _opacityTitle = 0.0;
       _opacitySubtitle = 0.0;
       _starSpeed = 8.0; // Hyperspace!
    });
    
    // 5. Transition to App
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StarfieldBackground(
        speedMultiplier: _starSpeed,
        child: Center(
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(seconds: 6),
            curve: Curves.easeOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: _opacityTitle,
                  child: Text(
                    'CODE QUEST',
                    style: GoogleFonts.pressStart2p(
                      color: const Color(0xFFD0E0FF), // Off-white/pale blue
                      fontSize: 32,
                      letterSpacing: 4,
                      shadows: [
                        BoxShadow(
                          color: const Color(0xFFD0E0FF).withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        )
                      ]
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: _opacitySubtitle,
                  child: Text(
                    'A JOURNEY THROUGH KNOWLEDGE',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFFA0B0E0), // Muted blue
                      fontSize: 16,
                      letterSpacing: 6,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

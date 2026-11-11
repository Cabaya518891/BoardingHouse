import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'form_page.dart';

class welcome extends StatefulWidget {
  const welcome({super.key});

  @override
  State<welcome> createState() => _welcomeState();
}

class _welcomeState extends State<welcome> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Setup fade & scale entrance animations for logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _goToFormPage();
    });
  }

  void _goToFormPage() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const form_page(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  // Soft decorative circle used in the background
  Widget _buildGlow(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  // Boarding house logo: a two-story house with lit windows and a door,
  // drawn in code (no image file needed)
  Widget _buildLogo() {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
      ),
      child: Center(
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Center(
            child: SizedBox(
              width: 76,
              height: 76,
              child: CustomPaint(painter: _BoardingHouseLogoPainter()),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            _goToFormPage, // Interactive: Tap anywhere on screen to skip delay immediately
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B2A41), Color(0xFF2F6FED)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Background decoration
              Positioned(top: -90, right: -70, child: _buildGlow(260, 0.06)),
              Positioned(top: 120, left: -80, child: _buildGlow(170, 0.05)),
              Positioned(bottom: -110, left: -60, child: _buildGlow(300, 0.06)),
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      // Animated Logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildLogo(),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // App name and tagline
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            const Text(
                              'Room for you',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'BOARDING HOUSE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Find a room that fits you.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 3),
                      // Interactive Visual Feedback
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap anywhere to skip',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Draws the boarding house mark: chimney, roof, two floors of windows, door
class _BoardingHouseLogoPainter extends CustomPainter {
  const _BoardingHouseLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint navy = Paint()..color = const Color(0xFF1B2A41);
    final Paint blue = Paint()..color = const Color(0xFF2F6FED);
    final Paint warm = Paint()..color = const Color(0xFFFFC857);

    // Chimney
    canvas.drawRect(Rect.fromLTWH(w * 0.68, h * 0.10, w * 0.10, h * 0.20), navy);

    // Roof
    final Path roof = Path()
      ..moveTo(w * 0.50, h * 0.04)
      ..lineTo(w * 0.98, h * 0.42)
      ..lineTo(w * 0.02, h * 0.42)
      ..close();
    canvas.drawPath(roof, blue);

    // Building body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.42, w * 0.72, h * 0.50),
        Radius.circular(w * 0.04),
      ),
      navy,
    );

    // Windows (lit)
    void window(double x, double y) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * x, h * y, w * 0.16, h * 0.13),
          Radius.circular(w * 0.02),
        ),
        warm,
      );
    }

    // Top floor: three rooms
    window(0.22, 0.49);
    window(0.42, 0.49);
    window(0.62, 0.49);

    // Ground floor: window, door, window
    window(0.22, 0.69);
    window(0.62, 0.69);

    // Door
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.42, h * 0.68, w * 0.16, h * 0.24),
        topLeft: Radius.circular(w * 0.08),
        topRight: Radius.circular(w * 0.08),
      ),
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
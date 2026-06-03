import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScale;
  late Animation<Offset> _textSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background: gradient simulating wheat field atmosphere
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 0.65, 1.0],
                colors: [
                  Color(0xFFF8F6F0),
                  Color(0xFFF0EDE4),
                  Color(0xFFD4C9A8),
                  Color(0xFF8B9A46),
                ],
              ),
            ),
          ),

          // Wheat field bottom pattern overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF6B7F2E).withOpacity(0.3),
                    const Color(0xFF4A6B1A).withOpacity(0.5),
                    const Color(0xFF3D5A14).withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Decorative wheat stalks pattern
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: CustomPaint(
              painter: _WheatFieldPainter(),
            ),
          ),

          // Dark top band
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 40,
            child: Container(color: Colors.black),
          ),

          // Dark bottom band
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 40,
            child: Container(color: Colors.black),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo with scale animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // English Title
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Pakistan Land',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B2A4A),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Records Authority',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B2A4A),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Urdu Title
                        Text(
                          'پاکستان لینڈ ریکارڈز اتھارٹی',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A5C2A),
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Language Buttons
                FadeTransition(
                  opacity: _buttonFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        // Urdu Button
                        Expanded(
                          child: _LanguageButton(
                            label: 'اردو',
                            isRtl: true,
                            onTap: _navigateToLogin,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // English Button
                        Expanded(
                          child: _LanguageButton(
                            label: 'English',
                            isRtl: false,
                            onTap: _navigateToLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isRtl;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(30),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A4A),
              letterSpacing: isRtl ? 0 : 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws stylized wheat stalk silhouettes
class _WheatFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw multiple wheat stalks across the bottom
    final int stalkCount = 25;
    for (int i = 0; i < stalkCount; i++) {
      final x = (size.width / stalkCount) * i + (size.width / stalkCount / 2);
      final baseY = size.height;
      final topY = size.height * (0.2 + (i % 3) * 0.1);

      // Alternate colors for depth
      final colorIndex = i % 4;
      final colors = [
        const Color(0xFF6B8E23).withOpacity(0.4),
        const Color(0xFF556B2F).withOpacity(0.3),
        const Color(0xFF8FBC8F).withOpacity(0.35),
        const Color(0xFF7CFC00).withOpacity(0.2),
      ];
      paint.color = colors[colorIndex];

      // Stalk line
      final path = Path();
      path.moveTo(x, baseY);

      // Slight curve for natural look
      final controlX = x + (i.isEven ? 3 : -3);
      path.quadraticBezierTo(controlX, (baseY + topY) / 2, x, topY);
      canvas.drawPath(path, paint);

      // Wheat head at top
      final headPaint = Paint()
        ..color = colors[colorIndex].withOpacity(0.6)
        ..style = PaintingStyle.fill;

      for (int j = 0; j < 4; j++) {
        final leafY = topY + j * 8;
        final leafPath = Path();
        leafPath.moveTo(x, leafY);
        leafPath.quadraticBezierTo(
          x + (j.isEven ? 8 : -8),
          leafY + 4,
          x,
          leafY + 8,
        );
        canvas.drawPath(leafPath, headPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

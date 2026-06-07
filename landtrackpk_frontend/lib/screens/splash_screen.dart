import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import '../widgets/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          DocumentFlipPageRoute(page: const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.tertiary, width: 4),
              ),
              child: const Center(
                child: Icon(Icons.account_balance_outlined, size: 60, color: AppColors.primary),
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'LandTrackPK',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 60,
              height: 2,
              color: AppColors.tertiary,
            ).animate().scaleX(delay: 600.ms, alignment: Alignment.center),
            const SizedBox(height: AppSpacing.lg),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.tertiary),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}

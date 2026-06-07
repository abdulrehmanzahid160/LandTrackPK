import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class VerifiedSeal extends StatelessWidget {
  final double size;

  const VerifiedSeal({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.tertiary, width: 2),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.tertiary, width: 1),
        ),
        child: Icon(
          Icons.verified_user_outlined,
          color: AppColors.tertiary,
          size: size * 0.4,
        ),
      ),
    )
        .animate()
        .scale(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutBack)
        .fadeIn();
  }
}

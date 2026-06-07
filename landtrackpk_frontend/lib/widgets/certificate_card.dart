import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CertificateCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasGuilloche;

  const CertificateCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.hasGuilloche = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: AppDecorations.certificateCard,
        child: Stack(
          children: [
            // Left gold border accent (width 4.0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4.0,
              child: Container(color: AppColors.tertiary),
            ),
            if (hasGuilloche)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/images/guilloche_pattern.png',
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

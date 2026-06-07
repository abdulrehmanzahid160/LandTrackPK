import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ServiceTile extends StatelessWidget {
  final IconData icon;
  final String englishLabel;
  final String urduLabel;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.icon,
    required this.englishLabel,
    required this.urduLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: AppDecorations.officialCard,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text(
              englishLabel,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              urduLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}

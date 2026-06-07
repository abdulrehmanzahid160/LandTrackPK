import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

enum StampStatus { verified, pending, resolved, rejected, disputed }

class StampBadge extends StatelessWidget {
  final StampStatus status;
  final String? customText;

  const StampBadge({
    super.key,
    required this.status,
    this.customText,
  });

  Color get _color {
    switch (status) {
      case StampStatus.verified:
      case StampStatus.pending:
        return AppColors.tertiary; // Gold
      case StampStatus.resolved:
        return AppColors.success; // Green
      case StampStatus.rejected:
      case StampStatus.disputed:
        return AppColors.error; // Red
    }
  }

  String get _text {
    if (customText != null) return customText!.toUpperCase();
    switch (status) {
      case StampStatus.verified: return 'VERIFIED';
      case StampStatus.pending: return 'PENDING';
      case StampStatus.resolved: return 'RESOLVED';
      case StampStatus.rejected: return 'REJECTED';
      case StampStatus.disputed: return 'DISPUTED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.087, // ~ -5 degrees
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: _color, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _text,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}

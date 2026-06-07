import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String> stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index % 2 != 0) {
          // Connecting line
          final stepIndex = index ~/ 2;
          final isCompleted = currentStep > stepIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
            ),
          );
        }

        // Step circle
        final stepIndex = index ~/ 2;
        final isCompleted = currentStep > stepIndex;
        final isActive = currentStep == stepIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isActive ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: isCompleted || isActive ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.surface, size: 16)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive ? AppColors.surface : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              stepLabels[stepIndex],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive || isCompleted ? AppColors.onSurface : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        );
      }),
    );
  }
}

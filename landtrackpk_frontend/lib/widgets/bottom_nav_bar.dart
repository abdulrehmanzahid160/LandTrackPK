import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          _buildItem(Icons.description_outlined, 'Records', 0),
          _buildItem(Icons.map_outlined, 'Map', 1),
          _buildItem(Icons.verified_user_outlined, 'Verify', 2),
          _buildItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
          ]
        ],
      ),
      label: label,
    );
  }
}

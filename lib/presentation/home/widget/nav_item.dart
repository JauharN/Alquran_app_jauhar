import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/components/spaces.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isTablet;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return isTablet
        ? InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isActive
                        ? AppColors.secondary
                        : AppColors.white.withValues(alpha: 150.0),
                    size: 24,
                  ),
                ],
              ),
            ),
          )
        : InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.secondary.withValues(alpha: 50.0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isActive ? AppColors.secondary : AppColors.white,
                    size: 24,
                  ),
                  const SpaceHeight(4.0),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isActive ? AppColors.secondary : AppColors.white,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

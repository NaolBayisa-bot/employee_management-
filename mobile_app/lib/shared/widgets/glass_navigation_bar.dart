import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';

/// Destination item for [GlassNavigationBar].
class GlassNavigationDestination {
  const GlassNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
}

/// Blurred bottom navigation bar with translucent surface and glowing primary active indicator.
///
/// NOTE: When using [GlassNavigationBar] in a [Scaffold], set `extendBody: true`
/// so that scrollable content flows naturally beneath the translucent blurred bar:
/// ```dart
/// Scaffold(
///   extendBody: true,
///   body: ...,
///   bottomNavigationBar: GlassNavigationBar(...),
/// )
/// ```
class GlassNavigationBar extends StatelessWidget {
  const GlassNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.blur = true,
  });

  final List<GlassNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    Widget barContent = SafeArea(
      top: false,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < destinations.length; i++)
              _buildItem(context, destinations[i], i == selectedIndex, i),
          ],
        ),
      ),
    );

    Widget background = Container(
      decoration: const BoxDecoration(
        color: AppColors.glassFill,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.0),
        ),
      ),
    );

    if (blur) {
      background = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppBlur.bar,
          sigmaY: AppBlur.bar,
        ),
        child: background,
      );
    }

    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(child: background),
          barContent,
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    GlassNavigationDestination destination,
    bool isSelected,
    int index,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              child: isSelected && destination.selectedIcon != null
                  ? destination.selectedIcon!
                  : destination.icon,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            destination.label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

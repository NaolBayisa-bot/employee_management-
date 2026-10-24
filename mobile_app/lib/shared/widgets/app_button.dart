import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';

enum AppButtonVariant {
  primary,
  secondary,
  text,
}

/// Customizable full-width or inline button implementing the design variants:
/// - [AppButtonVariant.primary]: Cyan to blue gradient with soft atmospheric glow.
/// - [AppButtonVariant.secondary]: Frosted glass surface with 1px border.
/// - [AppButtonVariant.text]: Transparent background with primary accent text.
///
/// Disables tap interactions and displays a spinner when [isLoading] is true.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
    this.isLoading = false,
    this.leadingIcon,
    this.height = 48.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool fullWidth;
  final bool isLoading;
  final Widget? leadingIcon;
  final double height;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isLoading) {
      child = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      final textStyle = GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
        color: _getTextColor(),
      );

      if (leadingIcon != null) {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: _getTextColor(), size: 18),
              child: leadingIcon!,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: textStyle),
          ],
        );
      } else {
        child = Text(label, style: textStyle);
      }
    }

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          decoration: BoxDecoration(
            gradient: _isEnabled
                ? AppColors.buttonGradient
                : LinearGradient(
                    colors: [
                      AppColors.buttonGradient.colors[0].withValues(alpha: 0.35),
                      AppColors.buttonGradient.colors[1].withValues(alpha: 0.35),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: _isEnabled
                ? const [
                    BoxShadow(
                      color: AppColors.buttonGlow,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.button),
              onTap: _isEnabled ? onPressed : null,
              child: Center(child: child),
            ),
          ),
        );
        break;

      case AppButtonVariant.secondary:
        button = Container(
          height: height,
          decoration: BoxDecoration(
            color: _isEnabled
                ? AppColors.glassFill
                : AppColors.glassFill.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: _isEnabled
                  ? AppColors.glassBorder
                  : AppColors.glassBorder.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.button),
              onTap: _isEnabled ? onPressed : null,
              child: Center(child: child),
            ),
          ),
        );
        break;

      case AppButtonVariant.text:
        button = SizedBox(
          height: height,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  _isEnabled ? AppColors.primary : AppColors.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            onPressed: _isEnabled ? onPressed : null,
            child: child,
          ),
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Color _getTextColor() {
    if (!_isEnabled) return AppColors.textDisabled;
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.onPrimary;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }
}

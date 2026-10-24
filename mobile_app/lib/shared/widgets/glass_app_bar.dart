import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';

/// Translucent, blurred top app bar implementing PreferredSizeWidget with
/// title in Space Grotesk, optional actions, and back button support.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.blur = true,
    this.bottom,
    this.height = kToolbarHeight,
  });

  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final bool blur;
  final PreferredSizeWidget? bottom;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(
        height + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    Widget? effectiveLeading = leading;

    if (effectiveLeading == null && automaticallyImplyLeading && canPop) {
      effectiveLeading = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.maybePop(context),
      );
    }

    final effectiveTitle = title ??
        (titleText != null
            ? Text(
                titleText!,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              )
            : null);

    Widget appBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: effectiveLeading,
      automaticallyImplyLeading: false,
      title: effectiveTitle,
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );

    Widget background = Container(
      decoration: const BoxDecoration(
        color: AppColors.glassFill,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder, width: 1.0),
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
        fit: StackFit.expand,
        children: [
          background,
          SafeArea(bottom: false, child: appBar),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/models/project.dart';
import '../../shared/models/task.dart';
import '../../shared/models/user.dart';

/// Spacing scale for layout, padding, and margins.
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Corner radius scale for surfaces, inputs, buttons, and sheets.
abstract final class AppRadius {
  static const double card = 20.0;
  static const double input = 14.0;
  static const double button = 14.0;
  static const double chip = 10.0;
  static const double sheet = 28.0;
  static const double dialog = 24.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius sheetRadius = BorderRadius.vertical(top: Radius.circular(sheet));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(dialog));
}

/// Blur radiuses for glassmorphism panels and navigation bars.
abstract final class AppBlur {
  static const double card = 14.0;
  static const double bar = 20.0;
}

/// Triple representing text color, tinted fill background, and border for domain tags.
@immutable
class StatusColorToken {
  const StatusColorToken({
    required this.text,
    required this.fill,
    required this.border,
  });

  final Color text;
  final Color fill;
  final Color border;
}

/// Color tokens conforming to the Dark Glassmorphism design system.
abstract final class AppColors {
  // --- Background Canvas & Gradient ---
  static const Color backgroundGradientStart = Color(0xFF0A0E1A);
  static const Color backgroundGradientEnd = Color(0xFF0F131F);
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundGradientStart, backgroundGradientEnd],
  );

  // --- Ambient Glow Orbs ---
  static const Color orbCyan = Color(0xFF22D3EE);
  static const Color orbViolet = Color(0xFF8B5CF6);
  static const Color orbBlue = Color(0xFF3B82F6);

  // --- Glassmorphic Shading ---
  static const Color glassFill = Color(0x14FFFFFF);         // 8% white
  static const Color glassFillPressed = Color(0x29FFFFFF);  // 16% white
  static const Color glassBorder = Color(0x24FFFFFF);       // 14% white
  static const Color glassHighlight = Color(0x33FFFFFF);    // 20% white

  // --- Typography & Dividers ---
  static const Color textPrimary = Color(0xFFE6EAF2);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF64748B);
  static const Color divider = Color(0x24FFFFFF);

  // --- Brand Accents ---
  static const Color primary = Color(0xFF8B5CF6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF3C1671);
  static const Color onPrimaryContainer = Color(0xFFE9DDFF);

  static const Color secondary = Color(0xFF22D3EE);
  static const Color onSecondary = Color(0xFF00363E);
  static const Color secondaryContainer = Color(0xFF004E5A);
  static const Color onSecondaryContainer = Color(0xFFA2EEFF);

  static const Color tertiary = Color(0xFF3B82F6);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // --- Button Gradients & Glows ---
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
  );
  static const Color buttonGlow = Color(0x5922D3EE);

  // --- Semantic Feedback ---
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorFill = Color(0x26EF4444);
  static const Color errorBorder = Color(0x59EF4444);

  static const Color success = Color(0xFF10B981);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successFill = Color(0x2610B981);
  static const Color successBorder = Color(0x5910B981);

  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningFill = Color(0x26F59E0B);
  static const Color warningBorder = Color(0x59F59E0B);

  // --- Task Status Colors ---
  static const Color statusTodo = Color(0xFF94A3B8);
  static const Color statusTodoFill = Color(0x2694A3B8);
  static const Color statusTodoBorder = Color(0x5994A3B8);

  static const Color statusInProgress = Color(0xFF22D3EE);
  static const Color statusInProgressFill = Color(0x2622D3EE);
  static const Color statusInProgressBorder = Color(0x5922D3EE);

  static const Color statusDone = Color(0xFF10B981);
  static const Color statusDoneFill = Color(0x2610B981);
  static const Color statusDoneBorder = Color(0x5910B981);

  // --- Task Priority Colors ---
  static const Color priorityLow = Color(0xFF3B82F6);
  static const Color priorityLowFill = Color(0x263B82F6);
  static const Color priorityLowBorder = Color(0x593B82F6);

  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityMediumFill = Color(0x26F59E0B);
  static const Color priorityMediumBorder = Color(0x59F59E0B);

  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityHighFill = Color(0x26EF4444);
  static const Color priorityHighBorder = Color(0x59EF4444);

  // --- Role Colors ---
  static const Color roleAdmin = Color(0xFF8B5CF6);
  static const Color roleAdminFill = Color(0x268B5CF6);
  static const Color roleAdminBorder = Color(0x598B5CF6);

  static const Color roleManager = Color(0xFF22D3EE);
  static const Color roleManagerFill = Color(0x2622D3EE);
  static const Color roleManagerBorder = Color(0x5922D3EE);

  static const Color roleEmployee = Color(0xFF3B82F6);
  static const Color roleEmployeeFill = Color(0x263B82F6);
  static const Color roleEmployeeBorder = Color(0x593B82F6);

  // --- User Status Colors ---
  static const Color userStatusPending = Color(0xFFF59E0B);
  static const Color userStatusPendingFill = Color(0x26F59E0B);
  static const Color userStatusPendingBorder = Color(0x59F59E0B);

  static const Color userStatusActive = Color(0xFF10B981);
  static const Color userStatusActiveFill = Color(0x2610B981);
  static const Color userStatusActiveBorder = Color(0x5910B981);

  static const Color userStatusDeactivated = Color(0xFFEF4444);
  static const Color userStatusDeactivatedFill = Color(0x26EF4444);
  static const Color userStatusDeactivatedBorder = Color(0x59EF4444);

  // --- Project Status Colors ---
  static const Color projectStatusActive = Color(0xFF10B981);
  static const Color projectStatusActiveFill = Color(0x2610B981);
  static const Color projectStatusActiveBorder = Color(0x5910B981);

  static const Color projectStatusArchived = Color(0xFF94A3B8);
  static const Color projectStatusArchivedFill = Color(0x2694A3B8);
  static const Color projectStatusArchivedBorder = Color(0x5994A3B8);

  // --- Surface Containers ---
  static const Color surface = Color(0xFF0F131F);
  static const Color surfaceDim = Color(0xFF0A0E1A);
  static const Color surfaceBright = Color(0xFF353946);
  static const Color surfaceContainerLowest = Color(0xFF0A0E1A);
  static const Color surfaceContainerLow = Color(0xFF171B28);
  static const Color surfaceContainer = Color(0xFF1B1F2C);
  static const Color surfaceContainerHigh = Color(0xFF262A37);
  static const Color surfaceContainerHighest = Color(0xFF313442);

  // --- Domain Helpers ---
  static StatusColorToken forTaskStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const StatusColorToken(
          text: statusTodo,
          fill: statusTodoFill,
          border: statusTodoBorder,
        );
      case TaskStatus.inProgress:
        return const StatusColorToken(
          text: statusInProgress,
          fill: statusInProgressFill,
          border: statusInProgressBorder,
        );
      case TaskStatus.done:
        return const StatusColorToken(
          text: statusDone,
          fill: statusDoneFill,
          border: statusDoneBorder,
        );
    }
  }

  static StatusColorToken forPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const StatusColorToken(
          text: priorityLow,
          fill: priorityLowFill,
          border: priorityLowBorder,
        );
      case TaskPriority.medium:
        return const StatusColorToken(
          text: priorityMedium,
          fill: priorityMediumFill,
          border: priorityMediumBorder,
        );
      case TaskPriority.high:
        return const StatusColorToken(
          text: priorityHigh,
          fill: priorityHighFill,
          border: priorityHighBorder,
        );
    }
  }

  static StatusColorToken forRole(Role? role) {
    switch (role) {
      case Role.admin:
        return const StatusColorToken(
          text: roleAdmin,
          fill: roleAdminFill,
          border: roleAdminBorder,
        );
      case Role.manager:
        return const StatusColorToken(
          text: roleManager,
          fill: roleManagerFill,
          border: roleManagerBorder,
        );
      case Role.employee:
        return const StatusColorToken(
          text: roleEmployee,
          fill: roleEmployeeFill,
          border: roleEmployeeBorder,
        );
      case null:
        return const StatusColorToken(
          text: textSecondary,
          fill: glassFill,
          border: glassBorder,
        );
    }
  }

  static StatusColorToken forUserStatus(UserStatus status) {
    switch (status) {
      case UserStatus.pending:
        return const StatusColorToken(
          text: userStatusPending,
          fill: userStatusPendingFill,
          border: userStatusPendingBorder,
        );
      case UserStatus.active:
        return const StatusColorToken(
          text: userStatusActive,
          fill: userStatusActiveFill,
          border: userStatusActiveBorder,
        );
      case UserStatus.deactivated:
        return const StatusColorToken(
          text: userStatusDeactivated,
          fill: userStatusDeactivatedFill,
          border: userStatusDeactivatedBorder,
        );
    }
  }

  static StatusColorToken forProjectStatus(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return const StatusColorToken(
          text: projectStatusActive,
          fill: projectStatusActiveFill,
          border: projectStatusActiveBorder,
        );
      case ProjectStatus.archived:
        return const StatusColorToken(
          text: projectStatusArchived,
          fill: projectStatusArchivedFill,
          border: projectStatusArchivedBorder,
        );
    }
  }
}

/// Monospace typography helper for technical numbers, code, and badges.
abstract final class AppText {
  static final TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle monoStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

/// ThemeExtension to expose the monospace TextStyle through the theme tree.
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  const AppTypographyExtension({required this.mono});

  final TextStyle mono;

  @override
  AppTypographyExtension copyWith({TextStyle? mono}) {
    return AppTypographyExtension(mono: mono ?? this.mono);
  }

  @override
  AppTypographyExtension lerp(
    covariant ThemeExtension<AppTypographyExtension>? other,
    double t,
  ) {
    if (other is! AppTypographyExtension) return this;
    return AppTypographyExtension(
      mono: TextStyle.lerp(mono, other.mono, t) ?? mono,
    );
  }
}

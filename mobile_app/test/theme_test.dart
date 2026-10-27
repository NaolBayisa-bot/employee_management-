import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:employee_management/core/theme/app_theme.dart';
import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/task.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppSpacing tokens', () {
    test('values match specification', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);
    });
  });

  group('AppRadius tokens', () {
    test('values match specification', () {
      expect(AppRadius.card, 20.0);
      expect(AppRadius.input, 14.0);
      expect(AppRadius.button, 14.0);
      expect(AppRadius.chip, 10.0);
      expect(AppRadius.sheet, 28.0);
      expect(AppRadius.dialog, 24.0);
    });
  });

  group('AppBlur tokens', () {
    test('values match specification', () {
      expect(AppBlur.card, 14.0);
      expect(AppBlur.bar, 20.0);
    });
  });

  group('AppColors tokens', () {
    test('canvas and gradient colors match dark glassmorphic palette', () {
      expect(AppColors.backgroundGradientStart, const Color(0xFF0A0E1A));
      expect(AppColors.backgroundGradientEnd, const Color(0xFF0F131F));
      expect(AppColors.backgroundGradient.colors, [
        const Color(0xFF0A0E1A),
        const Color(0xFF0F131F),
      ]);
    });

    test('glow orb colors match atmospheric palette', () {
      expect(AppColors.orbCyan, const Color(0xFF22D3EE));
      expect(AppColors.orbViolet, const Color(0xFF8B5CF6));
      expect(AppColors.orbBlue, const Color(0xFF3B82F6));
    });

    test('glass surfaces match opacity ratios', () {
      expect(AppColors.glassFill, const Color(0x14FFFFFF));
      expect(AppColors.glassFillPressed, const Color(0x29FFFFFF));
      expect(AppColors.glassBorder, const Color(0x24FFFFFF));
      expect(AppColors.glassHighlight, const Color(0x33FFFFFF));
    });

    test('text and divider colors', () {
      expect(AppColors.textPrimary, const Color(0xFFE6EAF2));
      expect(AppColors.textSecondary, const Color(0xFF94A3B8));
      expect(AppColors.textDisabled, const Color(0xFF64748B));
      expect(AppColors.divider, const Color(0x24FFFFFF));
    });

    test('primary, secondary and on colors', () {
      expect(AppColors.primary, const Color(0xFF8B5CF6));
      expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
      expect(AppColors.secondary, const Color(0xFF22D3EE));
      expect(AppColors.onSecondary, const Color(0xFF00363E));
      expect(AppColors.tertiary, const Color(0xFF3B82F6));
      expect(AppColors.onTertiary, const Color(0xFFFFFFFF));
    });

    test('semantic feedback colors', () {
      expect(AppColors.error, const Color(0xFFEF4444));
      expect(AppColors.onError, const Color(0xFFFFFFFF));
      expect(AppColors.errorFill, const Color(0x26EF4444));
      expect(AppColors.errorBorder, const Color(0x59EF4444));

      expect(AppColors.success, const Color(0xFF10B981));
      expect(AppColors.onSuccess, const Color(0xFFFFFFFF));
      expect(AppColors.successFill, const Color(0x2610B981));
      expect(AppColors.successBorder, const Color(0x5910B981));

      expect(AppColors.warning, const Color(0xFFF59E0B));
      expect(AppColors.onWarning, const Color(0xFFFFFFFF));
      expect(AppColors.warningFill, const Color(0x26F59E0B));
      expect(AppColors.warningBorder, const Color(0x59F59E0B));
    });

    test('task status tokens have tinted fill and border variants', () {
      final todo = AppColors.forTaskStatus(TaskStatus.todo);
      expect(todo.text, AppColors.statusTodo);
      expect(todo.fill, AppColors.statusTodoFill);
      expect(todo.border, AppColors.statusTodoBorder);

      final inProg = AppColors.forTaskStatus(TaskStatus.inProgress);
      expect(inProg.text, AppColors.statusInProgress);
      expect(inProg.fill, AppColors.statusInProgressFill);
      expect(inProg.border, AppColors.statusInProgressBorder);

      final done = AppColors.forTaskStatus(TaskStatus.done);
      expect(done.text, AppColors.statusDone);
      expect(done.fill, AppColors.statusDoneFill);
      expect(done.border, AppColors.statusDoneBorder);
    });

    test('priority tokens have tinted fill and border variants', () {
      final low = AppColors.forPriority(TaskPriority.low);
      expect(low.text, AppColors.priorityLow);
      expect(low.fill, AppColors.priorityLowFill);
      expect(low.border, AppColors.priorityLowBorder);

      final med = AppColors.forPriority(TaskPriority.medium);
      expect(med.text, AppColors.priorityMedium);
      expect(med.fill, AppColors.priorityMediumFill);
      expect(med.border, AppColors.priorityMediumBorder);

      final high = AppColors.forPriority(TaskPriority.high);
      expect(high.text, AppColors.priorityHigh);
      expect(high.fill, AppColors.priorityHighFill);
      expect(high.border, AppColors.priorityHighBorder);
    });

    test('role tokens have tinted fill and border variants', () {
      final admin = AppColors.forRole(Role.admin);
      expect(admin.text, AppColors.roleAdmin);
      expect(admin.fill, AppColors.roleAdminFill);
      expect(admin.border, AppColors.roleAdminBorder);

      final manager = AppColors.forRole(Role.manager);
      expect(manager.text, AppColors.roleManager);
      expect(manager.fill, AppColors.roleManagerFill);
      expect(manager.border, AppColors.roleManagerBorder);

      final employee = AppColors.forRole(Role.employee);
      expect(employee.text, AppColors.roleEmployee);
      expect(employee.fill, AppColors.roleEmployeeFill);
      expect(employee.border, AppColors.roleEmployeeBorder);
    });

    test('user status tokens have tinted fill and border variants', () {
      final pending = AppColors.forUserStatus(UserStatus.pending);
      expect(pending.text, AppColors.userStatusPending);
      expect(pending.fill, AppColors.userStatusPendingFill);
      expect(pending.border, AppColors.userStatusPendingBorder);

      final active = AppColors.forUserStatus(UserStatus.active);
      expect(active.text, AppColors.userStatusActive);
      expect(active.fill, AppColors.userStatusActiveFill);
      expect(active.border, AppColors.userStatusActiveBorder);

      final deactivated = AppColors.forUserStatus(UserStatus.deactivated);
      expect(deactivated.text, AppColors.userStatusDeactivated);
      expect(deactivated.fill, AppColors.userStatusDeactivatedFill);
      expect(deactivated.border, AppColors.userStatusDeactivatedBorder);
    });
  });

  group('Typography and TextTheme', () {
    test('AppText.mono provides JetBrains Mono style', () {
      expect(AppText.mono.fontFamily, contains('JetBrainsMono'));
      final custom = AppText.monoStyle(fontSize: 14);
      expect(custom.fontSize, 14);
      expect(custom.fontFamily, contains('JetBrainsMono'));
    });

    test('AppTheme includes typography extension with mono style', () {
      final ext = AppTheme.darkTheme.extension<AppTypographyExtension>();
      expect(ext, isNotNull);
      expect(ext!.mono.fontFamily, contains('JetBrainsMono'));
    });

    test('TextTheme contains all required styles with proper font families', () {
      final textTheme = AppTheme.darkTheme.textTheme;
      expect(textTheme.displaySmall, isNotNull);
      expect(textTheme.headlineSmall, isNotNull);
      expect(textTheme.titleLarge, isNotNull);
      expect(textTheme.titleMedium, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.bodySmall, isNotNull);
      expect(textTheme.labelLarge, isNotNull);

      // Space Grotesk for headings / title / label
      expect(textTheme.displaySmall!.fontFamily, contains('SpaceGrotesk'));
      expect(textTheme.headlineSmall!.fontFamily, contains('SpaceGrotesk'));
      expect(textTheme.titleLarge!.fontFamily, contains('SpaceGrotesk'));
      expect(textTheme.titleMedium!.fontFamily, contains('SpaceGrotesk'));
      expect(textTheme.labelLarge!.fontFamily, contains('SpaceGrotesk'));

      // Inter for body
      expect(textTheme.bodyLarge!.fontFamily, contains('Inter'));
      expect(textTheme.bodyMedium!.fontFamily, contains('Inter'));
      expect(textTheme.bodySmall!.fontFamily, contains('Inter'));
    });
  });

  group('AppTheme Dark M3 Component Themes', () {
    final theme = AppTheme.darkTheme;

    test('is dark and transparent scaffold', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, Colors.transparent);
    });

    test('AppBar and NavigationBar are transparent', () {
      expect(theme.appBarTheme.backgroundColor, Colors.transparent);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.navigationBarTheme.backgroundColor, Colors.transparent);
      expect(theme.navigationBarTheme.elevation, 0);
    });

    test('CardThemeData has glass fill and 20px radius', () {
      final card = theme.cardTheme;
      expect(card.color, AppColors.glassFill);
      expect(card.elevation, 0);
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppRadius.card));
      expect(shape.side.color, AppColors.glassBorder);
    });

    test('Buttons use AppColors.primary and 14px button radius', () {
      final elevated = theme.elevatedButtonTheme.style!;
      expect(
        elevated.backgroundColor?.resolve({}),
        AppColors.primary,
      );
      final elevatedShape = elevated.shape?.resolve({}) as RoundedRectangleBorder;
      expect(elevatedShape.borderRadius, BorderRadius.circular(AppRadius.button));

      final filled = theme.filledButtonTheme.style!;
      expect(
        filled.backgroundColor?.resolve({}),
        AppColors.primary,
      );

      final outlined = theme.outlinedButtonTheme.style!;
      expect(
        outlined.backgroundColor?.resolve({}),
        AppColors.glassFill,
      );

      final textBtn = theme.textButtonTheme.style!;
      expect(
        textBtn.foregroundColor?.resolve({}),
        AppColors.primary,
      );
    });

    test('InputDecoration has glass fill, light border, and primary focus border', () {
      final input = theme.inputDecorationTheme;
      expect(input.filled, isTrue);
      expect(input.fillColor, AppColors.glassFill);

      final enabled = input.enabledBorder as OutlineInputBorder;
      expect(enabled.borderRadius, BorderRadius.circular(AppRadius.input));
      expect(enabled.borderSide.color, AppColors.glassBorder);

      final focused = input.focusedBorder as OutlineInputBorder;
      expect(focused.borderRadius, BorderRadius.circular(AppRadius.input));
      expect(focused.borderSide.color, AppColors.primary);
      expect(focused.borderSide.width, 1.5);
    });

    test('ChipThemeData uses glass fill, chip radius 10, and primary selected color', () {
      final chip = theme.chipTheme;
      expect(chip.backgroundColor, AppColors.glassFill);
      expect(chip.selectedColor, AppColors.primary.withValues(alpha: 0.2));
      final shape = chip.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppRadius.chip));
    });

    test('SnackBar is floating with glass container styling', () {
      final snack = theme.snackBarTheme;
      expect(snack.behavior, SnackBarBehavior.floating);
      expect(snack.backgroundColor, AppColors.surfaceContainerHigh);
      final shape = snack.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppRadius.card));
    });

    test('Dialog and BottomSheet use surface container and respective radiuses', () {
      final dialog = theme.dialogTheme;
      expect(dialog.backgroundColor, AppColors.surfaceContainer);
      final dShape = dialog.shape as RoundedRectangleBorder;
      expect(dShape.borderRadius, BorderRadius.circular(AppRadius.dialog));

      final sheet = theme.bottomSheetTheme;
      expect(sheet.backgroundColor, AppColors.surfaceContainer);
      final sShape = sheet.shape as RoundedRectangleBorder;
      expect(
        sShape.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      );
    });

    test('TabBar, FloatingActionButton, ListTile, Divider, ProgressIndicator', () {
      expect(theme.tabBarTheme.indicatorColor, AppColors.primary);
      expect(theme.tabBarTheme.labelColor, AppColors.primary);

      expect(theme.floatingActionButtonTheme.backgroundColor, AppColors.primary);
      final fabShape =
          theme.floatingActionButtonTheme.shape as RoundedRectangleBorder;
      expect(fabShape.borderRadius, BorderRadius.circular(AppRadius.card));

      expect(theme.listTileTheme.iconColor, AppColors.primary);
      expect(theme.dividerTheme.color, AppColors.divider);
      expect(theme.progressIndicatorTheme.color, AppColors.primary);
    });
  });

  group('Acceptance Test: Primary color propagation in one place', () {
    test('Overriding primary changes buttons, focus rings, and chips everywhere', () {
      const customPrimary = Color(0xFF00E676); // Bright green
      final customTheme = AppTheme.buildDarkTheme(customPrimary);

      // ColorScheme
      expect(customTheme.colorScheme.primary, customPrimary);

      // Elevated button
      expect(
        customTheme.elevatedButtonTheme.style!.backgroundColor?.resolve({}),
        customPrimary,
      );

      // Filled button
      expect(
        customTheme.filledButtonTheme.style!.backgroundColor?.resolve({}),
        customPrimary,
      );

      // Text button
      expect(
        customTheme.textButtonTheme.style!.foregroundColor?.resolve({}),
        customPrimary,
      );

      // InputDecoration focused border
      final focusedBorder =
          customTheme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(focusedBorder.borderSide.color, customPrimary);

      // Chip selected color
      expect(
        customTheme.chipTheme.selectedColor,
        customPrimary.withValues(alpha: 0.2),
      );

      // FAB & ProgressIndicator
      expect(
        customTheme.floatingActionButtonTheme.backgroundColor,
        customPrimary,
      );
      expect(customTheme.progressIndicatorTheme.color, customPrimary);
    });
  });

  group('AppBackground widget test', () {
    testWidgets('renders gradient canvas and orbs behind child screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          builder: (context, child) => AppBackground(child: child!),
          home: const Scaffold(
            body: Center(child: Text('Test Child Screen')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBackground), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Test Child Screen'), findsOneWidget);
    });
  });
}

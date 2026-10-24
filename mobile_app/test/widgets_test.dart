import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/design_preview/design_preview_screen.dart';
import 'package:mobile_app/shared/models/project.dart';
import 'package:mobile_app/shared/models/task.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_background.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/avatar.dart';
import 'package:mobile_app/shared/widgets/glass_card.dart';
import 'package:mobile_app/shared/widgets/status_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget wrapWithTheme(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      builder: (context, c) => AppBackground(child: c!),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppButton widget tests', () {
    testWidgets('loading disables taps and displays spinner',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        wrapWithTheme(
          AppButton(
            label: 'Submit',
            isLoading: true,
            onPressed: () => tapCount++,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(tapCount, 0, reason: 'Tapping while loading must not fire onPressed');
    });

    testWidgets('enabled button invokes onPressed when tapped',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        wrapWithTheme(
          AppButton(
            label: 'Submit',
            isLoading: false,
            onPressed: () => tapCount++,
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(tapCount, 1);
    });

    testWidgets('renders secondary and text variants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const Column(
            children: [
              AppButton(label: 'Secondary', variant: AppButtonVariant.secondary),
              AppButton(label: 'Text', variant: AppButtonVariant.text),
            ],
          ),
        ),
      );

      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
    });
  });

  group('Avatar widget tests', () {
    test('extractInitials handles all edge cases', () {
      // Empty and whitespace
      expect(Avatar.extractInitials(''), '?');
      expect(Avatar.extractInitials(null), '?');
      expect(Avatar.extractInitials('   '), '?');

      // Single word
      expect(Avatar.extractInitials('Alice'), 'A');
      expect(Avatar.extractInitials('bob'), 'B');

      // Two words
      expect(Avatar.extractInitials('John Doe'), 'JD');
      expect(Avatar.extractInitials('ada lovelace'), 'AL');

      // Very long names (first two words used)
      expect(
        Avatar.extractInitials('Alexandria Bartholomew Constantinos Demetrius'),
        'AB',
      );
    });

    testWidgets('renders initials and respects size variants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const Column(
            children: [
              Avatar(name: 'John Doe', size: AvatarSize.small),
              Avatar(name: 'Alice', size: AvatarSize.medium),
              Avatar(name: '', size: AvatarSize.large),
            ],
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });
  });

  group('StatusChip widget tests', () {
    testWidgets('taskStatus named constructor displays spec label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Column(
            children: [
              StatusChip.taskStatus(TaskStatus.todo),
              StatusChip.taskStatus(TaskStatus.inProgress),
              StatusChip.taskStatus(TaskStatus.done),
            ],
          ),
        ),
      );

      expect(find.text('To do'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('priority named constructor displays spec label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Column(
            children: [
              StatusChip.priority(TaskPriority.low),
              StatusChip.priority(TaskPriority.medium),
              StatusChip.priority(TaskPriority.high),
            ],
          ),
        ),
      );

      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('role named constructor displays spec server string or dash',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Column(
            children: [
              StatusChip.role(Role.admin),
              StatusChip.role(Role.manager),
              StatusChip.role(Role.employee),
              StatusChip.role(null),
            ],
          ),
        ),
      );

      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('MANAGER'), findsOneWidget);
      expect(find.text('EMPLOYEE'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('userStatus named constructor displays server string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Column(
            children: [
              StatusChip.userStatus(UserStatus.pending),
              StatusChip.userStatus(UserStatus.active),
              StatusChip.userStatus(UserStatus.deactivated),
            ],
          ),
        ),
      );

      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('DEACTIVATED'), findsOneWidget);
    });

    testWidgets('projectStatus named constructor displays server string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Column(
            children: [
              StatusChip.projectStatus(ProjectStatus.active),
              StatusChip.projectStatus(ProjectStatus.archived),
            ],
          ),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('ARCHIVED'), findsOneWidget);
    });
  });

  group('GlassCard widget tests', () {
    testWidgets('renders child and responds to onTap',
        (WidgetTester tester) async {
      int tapped = 0;

      await tester.pumpWidget(
        wrapWithTheme(
          GlassCard(
            onTap: () => tapped++,
            child: const Text('Interactive Card'),
          ),
        ),
      );

      expect(find.text('Interactive Card'), findsOneWidget);
      await tester.tap(find.text('Interactive Card'));
      await tester.pumpAndSettle();

      expect(tapped, 1);
    });
  });

  group('DesignPreviewScreen gallery test', () {
    testWidgets('renders all major sections and elements in debug mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          builder: (context, c) => AppBackground(child: c!),
          home: const DesignPreviewScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Design System Gallery'), findsOneWidget);
      expect(find.text('1. Typography & MonoText'), findsOneWidget);
      expect(find.text('2. AppButton Variants'), findsOneWidget);
      expect(find.text('3. AppTextField States'), findsOneWidget);
      expect(find.text('4. StatusChip Badges (All Types)'), findsOneWidget);
      expect(find.text('5. Avatar Initials & Sizes'), findsOneWidget);
      expect(find.text('6. GlassCard Interaction & Blur Modes'), findsOneWidget);
      expect(find.text('7. InfoRow Key-Value Details'), findsOneWidget);
      expect(find.text('8. Feedback & Skeleton Views'), findsOneWidget);
      expect(find.text('9. Dialogs, Bottom Sheets & SnackBars'), findsOneWidget);
    });
  });
}

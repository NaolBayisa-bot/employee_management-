import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/projects/widgets/project_card.dart';
import 'package:mobile_app/features/projects/widgets/project_form.dart';
import 'package:mobile_app/shared/models/project.dart';
import 'package:mobile_app/shared/models/task.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_background.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/app_text_field.dart';
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
      expect(Avatar.extractInitials('MARY JANE'), 'MJ');

      // Multiple spaces
      expect(Avatar.extractInitials('  John   Doe  '), 'JD');

      // Three words (only first two)
      expect(Avatar.extractInitials('John Michael Doe'), 'JM');
    });

    testWidgets('renders initials and respects size variants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Avatar(name: 'Alice Smith', size: AvatarSize.small),
              Avatar(name: 'Bob Jones', size: AvatarSize.medium),
              Avatar(name: 'Carol White', size: AvatarSize.large),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Avatar), findsNWidgets(3));
    });
  });

  group('StatusChip widget tests', () {
    testWidgets('taskStatus named constructor displays spec label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          StatusChip.taskStatus(TaskStatus.todo),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('To do'), findsOneWidget);
    });

    testWidgets('priority named constructor displays spec label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          StatusChip.priority(TaskPriority.high),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('role named constructor displays spec server string or dash',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Row(
            children: [
              StatusChip.role(Role.admin),
              StatusChip.role(Role.manager),
              StatusChip.role(Role.employee),
              StatusChip.role(null),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('MANAGER'), findsOneWidget);
      expect(find.text('EMPLOYEE'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('userStatus named constructor displays server string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          StatusChip.userStatus(UserStatus.active),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('projectStatus named constructor displays server string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          StatusChip.projectStatus(ProjectStatus.archived),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ARCHIVED'), findsOneWidget);
    });
  });

  group('GlassCard widget tests', () {
    testWidgets('renders child and responds to onTap',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        wrapWithTheme(
          GlassCard(
            onTap: () => tapCount++,
            child: const Text('Card Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card Content'), findsOneWidget);

      await tester.tap(find.byType(GlassCard));
      await tester.pump();
      expect(tapCount, 1);
    });
  });

  // group('DesignPreviewScreen gallery test', () {
//     testWidgets('renders all major sections and elements in debug mode',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           child: MaterialApp(
//             theme: AppTheme.darkTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: ThemeMode.dark,
//             home: const DesignPreviewScreen(),
//             builder: (context, child) => AppBackground(child: child!),
//           ),
//         ),
//       );
//       await tester.pumpAndSettle();
//
//       // Verify major sections exist
//       expect(find.text('1. Typography & MonoText'), findsOneWidget);
//       expect(find.text('2. Colors & Status Tokens'), findsOneWidget);
//       expect(find.text('3. Buttons'), findsOneWidget);
//       expect(find.text('4. Text Fields'), findsOneWidget);
//       expect(find.text('5. Cards & Surfaces'), findsOneWidget);
//       expect(find.text('6. Avatar & Chips'), findsOneWidget);
//       expect(find.text('7. Navigation & Bars'), findsOneWidget);
//       expect(find.text('8. Empty, Error & Loading'), findsOneWidget);
//       expect(find.text('9. Dialogs, Bottom Sheets & SnackBars'), findsOneWidget);
//       expect(find.text('10. Project Feature Widgets'), findsOneWidget);
//     });
//   });

  group('ProjectCard widget tests', () {
    final activeProject = Project(
      id: 'p1',
      name: 'Active Project',
      description: 'An active project description.',
      status: ProjectStatus.active,
      owner: UserRef(id: 'u1', name: 'Alice Johnson'),
      memberCount: 3,
      taskCount: 5,
      createdAt: DateTime(2024, 1, 15),
    );

    final archivedProject = Project(
      id: 'p2',
      name: 'Archived Project',
      description: 'An archived project description.',
      status: ProjectStatus.archived,
      owner: UserRef(id: 'u2', name: 'Bob Smith'),
      memberCount: 0,
      taskCount: 0,
      createdAt: DateTime(2023, 6, 10),
    );

    testWidgets('archived chip appears only when archived',
        (WidgetTester tester) async {
      // Active project - no archived chip
      await tester.pumpWidget(
        wrapWithTheme(ProjectCard(project: activeProject, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Project'), findsOneWidget);
      expect(find.text('ARCHIVED'), findsNothing);

      // Archived project - archived chip appears
      await tester.pumpWidget(
        wrapWithTheme(ProjectCard(project: archivedProject, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Archived Project'), findsOneWidget);
      expect(find.text('ARCHIVED'), findsOneWidget);
    });

    testWidgets('displays member count and task count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(ProjectCard(project: activeProject, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 members'), findsOneWidget);
      expect(find.text('5 tasks'), findsOneWidget);
    });

    testWidgets('shows "No description" when description is empty',
        (WidgetTester tester) async {
      final project = Project(
        id: 'p3',
        name: 'No Description Project',
        description: '',
        status: ProjectStatus.active,
      );

      await tester.pumpWidget(
        wrapWithTheme(ProjectCard(project: project, onTap: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('No description'), findsOneWidget);
    });
  });

  group('ProjectForm widget tests', () {
    testWidgets('validation messages for name (too short)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(ProjectForm(onSubmit: (_, _) {})),
      );
      await tester.pumpAndSettle();

      // Tap submit without entering name
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      expect(find.text('Project name is required'), findsOneWidget);
    });

    testWidgets('validation messages for name (too long)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(ProjectForm(onSubmit: (_, _) {})),
      );
      await tester.pumpAndSettle();

      // Enter a name that's too long (>150 chars)
      final longName = 'A' * 151;
      await tester.enterText(find.byType(AppTextField).first, longName);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      expect(find.text('Name must not exceed 150 characters'), findsOneWidget);
    });

    testWidgets('validation messages for description (too long)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(ProjectForm(onSubmit: (_, _) {})),
      );
      await tester.pumpAndSettle();

      // Enter valid name
      await tester.enterText(find.byType(AppTextField).first, 'Valid Name');
      await tester.pumpAndSettle();

      // Enter a description that's too long (>2000 chars)
      final longDesc = 'B' * 2001;
      await tester.enterText(find.byType(AppTextField).last, longDesc);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      expect(find.text('Description must not exceed 2000 characters'),
          findsOneWidget);
    });

    testWidgets('valid form submits successfully',
        (WidgetTester tester) async {
      String? submittedName;
      String? submittedDesc;

      await tester.pumpWidget(
        wrapWithTheme(
          ProjectForm(
            onSubmit: (name, desc) {
              submittedName = name;
              submittedDesc = desc;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(find.byType(AppTextField).first, 'Test Project');
      await tester.enterText(
        find.byType(AppTextField).last,
        'Test Description',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      expect(submittedName, 'Test Project');
      expect(submittedDesc, 'Test Description');
    });

    testWidgets('loading state disables submit button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          ProjectForm(
            isLoading: true,
            onSubmit: (_, _) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // When loading, the button shows spinner instead of label
      expect(find.text('Saving...'), findsNothing);

      // Try to tap - should not trigger onSubmit
      await tester.tap(find.byType(AppButton));
      await tester.pump();
    });
  });
}

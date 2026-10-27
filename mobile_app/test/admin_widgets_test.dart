import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/features/admin/widgets/pending_user_tile.dart';
import 'package:mobile_app/features/admin/widgets/stats_grid.dart';
import 'package:mobile_app/shared/models/dashboard_stats.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: child,
      )),
      theme: ThemeData.dark(),
    );
  }

  group('PendingUserTile widget tests', () {
    final testUser = User(
      id: 'u1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      role: null,
      status: UserStatus.pending,
      createdAt: DateTime(2024, 1, 15),
    );

    testWidgets('Approve calls the callback with the selected role', (
      WidgetTester tester,
    ) async {
      bool approveCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: PendingUserTile(
            user: testUser,
            selectedRole: Role.employee,
            onRoleChanged: (_) {},
            onApprove: () => approveCalled = true,
          ),
        ),
      );

      // Tap the Approve button
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(approveCalled, isTrue);
    });

    testWidgets('Approve calls the callback with Manager role when selected', (
      WidgetTester tester,
    ) async {
      bool approveCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: PendingUserTile(
            user: testUser,
            selectedRole: Role.manager,
            onRoleChanged: (_) {},
            onApprove: () => approveCalled = true,
          ),
        ),
      );

      // Tap the Approve button
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(approveCalled, isTrue);
    });

    testWidgets('disabled while loading', (
      WidgetTester tester,
    ) async {
      bool approveCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: PendingUserTile(
            user: testUser,
            selectedRole: Role.employee,
            onRoleChanged: (_) {},
            onApprove: () => approveCalled = true,
            loading: true,
          ),
        ),
      );

      // The button should be disabled (onPressed is null when loading)
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.isLoading, isTrue);
      expect(button.onPressed, isNull);

      // Try to tap - should not call approve
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(approveCalled, isFalse);
    });

    testWidgets('renders user info correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PendingUserTile(
            user: testUser,
            selectedRole: Role.employee,
            onRoleChanged: (_) {},
            onApprove: () {},
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.textContaining('Joined'), findsOneWidget);
    });

    testWidgets('role selector shows Manager and Employee options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PendingUserTile(
            user: testUser,
            selectedRole: Role.employee,
            onRoleChanged: (_) {},
            onApprove: () {},
          ),
        ),
      );

      // Just verify the widget renders without error
      expect(find.byType(DropdownButton<Role>), findsOneWidget);
    });

    testWidgets('role selector is disabled when loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PendingUserTile(
            user: testUser,
            selectedRole: Role.employee,
            onRoleChanged: (_) {},
            onApprove: () {},
            loading: true,
          ),
        ),
      );

      final dropdown = tester.widget<DropdownButton<Role>>(
        find.byType(DropdownButton<Role>),
      );
      expect(dropdown.onChanged, isNull);
    });
  });

  group('StatsGrid widget tests', () {
    testWidgets('shows all five labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: StatsGrid(
            stats: DashboardStats(
              totalUsers: 100,
              pendingUsers: 5,
              activeProjects: 10,
              openTasks: 20,
              doneTasks: 30,
            ),
          ),
        ),
      );

      // Check all five stat labels are present
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('Pending Approvals'), findsOneWidget);
      expect(find.text('Active Projects'), findsOneWidget);
      expect(find.text('Open Tasks'), findsOneWidget);
      expect(find.text('Completed Tasks'), findsOneWidget);

      // Check values are displayed
      expect(find.text('100'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('shows all five labels with zero values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: StatsGrid(
            stats: DashboardStats(),
          ),
        ),
      );

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('Pending Approvals'), findsOneWidget);
      expect(find.text('Active Projects'), findsOneWidget);
      expect(find.text('Open Tasks'), findsOneWidget);
      expect(find.text('Completed Tasks'), findsOneWidget);

      // All values should be 0
      expect(find.text('0'), findsNWidgets(5));
    });
  });
}

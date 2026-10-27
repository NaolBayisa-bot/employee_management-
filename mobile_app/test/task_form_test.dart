import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/features/tasks/widgets/task_form.dart';
import 'package:mobile_app/shared/models/task.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final sampleMembers = [
    ProjectMember(id: 'm1', name: 'Alice Johnson', role: Role.admin),
    ProjectMember(id: 'm2', name: 'Bob Smith', role: Role.manager),
    ProjectMember(id: 'm3', name: 'Carol White', role: Role.employee),
  ];

  Widget buildTestWidget({
    required Widget child,
  }) {
    return MaterialApp(
      home: Scaffold(body: child),
      theme: ThemeData.dark(),
    );
  }

  group('TaskForm validation tests', () {
    testWidgets('empty title shows validation error and blocks submit', (
      WidgetTester tester,
    ) async {
      bool submitCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: TaskForm(
            members: sampleMembers,
            onSubmit: (values) {
              submitCalled = true;
            },
          ),
        ),
      );

      // Tap submit without entering title
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Should show validation error
      expect(find.text('Title is required'), findsOneWidget);
      expect(submitCalled, isFalse);
    });

    testWidgets('title too short shows validation error', (
      WidgetTester tester,
    ) async {
      bool submitCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: TaskForm(
            members: sampleMembers,
            onSubmit: (_) => submitCalled = true,
          ),
        ),
      );

      // Enter 1 character title
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(find.text('Title must be at least 2 characters'), findsOneWidget);
      expect(submitCalled, isFalse);
    });

    testWidgets('title too long shows validation error', (
      WidgetTester tester,
    ) async {
      bool submitCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: TaskForm(
            members: sampleMembers,
            onSubmit: (_) => submitCalled = true,
          ),
        ),
      );

      // Enter 201 characters title
      final longTitle = 'A' * 201;
      await tester.enterText(find.byType(TextFormField).first, longTitle);
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(find.text('Title must not exceed 200 characters'), findsOneWidget);
      expect(submitCalled, isFalse);
    });

    testWidgets('description too long shows validation error', (
      WidgetTester tester,
    ) async {
      bool submitCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: TaskForm(
            members: sampleMembers,
            onSubmit: (_) => submitCalled = true,
          ),
        ),
      );

      // Enter valid title
      await tester.enterText(find.byType(TextFormField).first, 'Valid Title');
      // Enter too long description (5001 chars)
      final longDesc = 'A' * 5001;
      await tester.enterText(find.byType(TextFormField).last, longDesc);
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(find.text('Description must not exceed 5000 characters'),
          findsOneWidget);
      expect(submitCalled, isFalse);
    });

    testWidgets('valid form calls onSubmit with correct values', (
      WidgetTester tester,
    ) async {
      TaskFormValues? capturedValues;

      await tester.pumpWidget(
        buildTestWidget(
          child: TaskForm(
            members: sampleMembers,
            onSubmit: (values) => capturedValues = values,
          ),
        ),
      );

      // Fill in valid data
      await tester.enterText(find.byType(TextFormField).first, 'Test Task');
      await tester.enterText(find.byType(TextFormField).last, 'Test description');
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(capturedValues, isNotNull);
      expect(capturedValues!.title, equals('Test Task'));
      expect(capturedValues!.description, equals('Test description'));
      expect(capturedValues!.assigneeId, isNull);
      expect(capturedValues!.dueDate, isNull);
      expect(capturedValues!.priority, equals(TaskPriority.medium));
    });

    testWidgets('prefilled form populates all fields correctly', (
      WidgetTester tester,
    ) async {
      final initialTask = Task(
        id: 't1',
        title: 'Existing Task',
        description: 'Existing description',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        projectId: 'p1',
        assignee: UserRef(id: 'm2', name: 'Bob Smith'),
        createdAt: DateTime(2024, 1, 15),
        dueDate: DateTime(2024, 10, 30),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: TaskForm(
            initialTask: initialTask,
            members: sampleMembers,
            onSubmit: (_) {},
          ),
        ),
      );

      // Check title field
      expect(find.text('Existing Task'), findsOneWidget);
      // Check description field
      expect(find.text('Existing description'), findsOneWidget);
      // Check assignee picker shows Bob Smith
      expect(find.text('Bob Smith'), findsOneWidget);
      // Check priority selector shows High
      expect(find.text('High'), findsOneWidget);
      // Check due date field shows the date
      expect(find.textContaining('Oct 30'), findsOneWidget);
    });

    testWidgets('loading state disables submit button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: TaskForm(
            members: sampleMembers,
            isLoading: true,
            onSubmit: (_) {},
          ),
        ),
      );

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.isLoading, isTrue);
      expect(button.onPressed, isNull);
    });
  });
}

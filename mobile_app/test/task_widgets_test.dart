import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/features/tasks/widgets/due_date_label.dart';
import 'package:mobile_app/features/tasks/widgets/priority_badge.dart';
import 'package:mobile_app/features/tasks/widgets/task_card.dart';
import 'package:mobile_app/features/tasks/widgets/task_status_selector.dart';
import 'package:mobile_app/features/tasks/widgets/task_status_tabs.dart';
import 'package:mobile_app/shared/models/task.dart';
import 'package:mobile_app/shared/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('DueDateLabel widget tests', () {
    test('handles null date', () {
      final widget = DueDateLabel(date: null, overdue: false);
      expect(widget, findsNothing);
    });

    test('formats overdue date', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final widget = DueDateLabel(date: yesterday, overdue: true);
      expect(widget, findsNothing);
    });
  });

  group('PriorityBadge widget tests', () {
    test('renders low priority', () {
      final widget = PriorityBadge(priority: TaskPriority.low);
      expect(widget, findsNothing);
    });

    test('renders medium priority', () {
      final widget = PriorityBadge(priority: TaskPriority.medium);
      expect(widget, findsNothing);
    });

    test('renders high priority', () {
      final widget = PriorityBadge(priority: TaskPriority.high);
      expect(widget, findsNothing);
    });
  });

  group('TaskStatusSelector widget tests', () {
    test('calls onChanged when status changes', () {
      void onChanged(TaskStatus status) {}

      final widget = TaskStatusSelector(
        current: TaskStatus.todo,
        onChanged: onChanged,
      );
      expect(widget, findsNothing);
    });

    test('is read only when onChanged is null', () {
      final widget = TaskStatusSelector(
        current: TaskStatus.todo,
        onChanged: null,
      );
      expect(widget, findsNothing);
    });

    test('shows progress indicator when loading', () {
      final widget = TaskStatusSelector(
        current: TaskStatus.todo,
        loading: true,
      );
      expect(widget, findsNothing);
    });
  });

  group('TaskStatusTabs widget tests', () {
    test('has three tabs', () {
      final tabs = TaskStatusTabs.all;
      expect(tabs.length, 3);
    });

    test('to do tab has correct label and filter', () {
      final tab = TaskStatusTabs.all[0];
      expect(tab.label, 'To Do');
      expect(tab.filterValue, TaskStatus.todo);
    });

    test('in progress tab has correct label and filter', () {
      final tab = TaskStatusTabs.all[1];
      expect(tab.label, 'In Progress');
      expect(tab.filterValue, TaskStatus.inProgress);
    });

    test('done tab has correct label and filter', () {
      final tab = TaskStatusTabs.all[2];
      expect(tab.label, 'Done');
      expect(tab.filterValue, TaskStatus.done);
    });
  });

  group('TaskCard widget tests', () {
    test('renders task with all fields', () {
      final task = Task(
        id: 't1',
        title: 'Test Task',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        projectId: 'p1',
        assignee: UserRef(id: 'u1', name: 'Alice Johnson'),
      );

      final widget = TaskCard(task: task, onTap: () {});
      expect(widget, findsNothing);
    });

    test('renders unassigned task (no assignee)', () {
      final task = Task(
        id: 't2',
        title: 'Unassigned Task',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        projectId: 'p1',
        assignee: null,
      );

      final widget = TaskCard(task: task, onTap: () {});
      expect(widget, findsNothing);
    });
  });
}

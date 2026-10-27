import 'package:mobile_app/shared/models/task.dart';

/// Helper data class describing the three tabs used by My tasks.
///
/// Each tab has a label (display text) and a filter value (used to filter tasks).
class TaskStatusTabs {
  const TaskStatusTabs._();

  /// All three task status tabs in the order they appear in the UI.
  static const List<TaskStatusTab> all = [
    TaskStatusTab(
      label: 'To Do',
      filterValue: TaskStatus.todo,
    ),
    TaskStatusTab(
      label: 'In Progress',
      filterValue: TaskStatus.inProgress,
    ),
    TaskStatusTab(
      label: 'Done',
      filterValue: TaskStatus.done,
    ),
  ];
}

/// A single tab description.
class TaskStatusTab {
  const TaskStatusTab({
    required this.label,
    required this.filterValue,
  });

  /// Display label for the tab (e.g., 'To Do', 'In Progress', 'Done').
  final String label;

  /// Filter value to apply when this tab is selected (e.g., [TaskStatus.todo]).
  final TaskStatus filterValue;
}
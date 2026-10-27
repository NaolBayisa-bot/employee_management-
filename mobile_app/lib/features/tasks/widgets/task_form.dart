// Task form widget.
//
// Form for creating/editing tasks with title, description, assignee, due date,
// priority, validation, and submit button.

import 'package:flutter/material.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/tasks/widgets/assignee_picker.dart';
import 'package:employee_management/features/tasks/widgets/date_picker_field.dart';
import 'package:employee_management/features/tasks/widgets/priority_selector.dart';
import 'package:employee_management/shared/models/task.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_button.dart';
import 'package:employee_management/shared/widgets/app_text_field.dart';

class TaskFormValues {
  const TaskFormValues({
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.dueDate,
    required this.priority,
  });

  final String title;
  final String description;
  final String? assigneeId;
  final DateTime? dueDate;
  final TaskPriority priority;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'assigneeId': assigneeId,
        'dueDate': dueDate == null ? null : _formatDateOnly(dueDate!),
        'priority': priority.toServerValue(),
      };

  static String _formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

typedef TaskFormSubmit = void Function(TaskFormValues values);

class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    this.initialTask,
    this.members = const [],
    this.submitLabel = 'Create Task',
    this.isLoading = false,
    this.onSubmit,
  });

  final Task? initialTask;
  final List<ProjectMember> members;
  final String submitLabel;
  final bool isLoading;
  final TaskFormSubmit? onSubmit;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedAssigneeId;
  DateTime? _selectedDueDate;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialTask?.description ?? '');
    _selectedAssigneeId = widget.initialTask?.assignee?.id;
    _selectedDueDate = widget.initialTask?.dueDate;
    _selectedPriority = widget.initialTask?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Title is required';
    }
    if (text.length < 2) {
      return 'Title must be at least 2 characters';
    }
    if (text.length > 200) {
      return 'Title must not exceed 200 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 5000) {
      return 'Description must not exceed 5000 characters';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call(TaskFormValues(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assigneeId: _selectedAssigneeId,
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          AppTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Enter task title',
            validator: _validateTitle,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            leadingIcon: const Icon(Icons.title_outlined, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),

          // Description field
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter task description (optional)',
            validator: _validateDescription,
            multiline: true,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            leadingIcon: const Icon(Icons.description_outlined, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),

          // Assignee picker
          AssigneePicker(
            members: widget.members,
            selectedId: _selectedAssigneeId,
            onChanged: (id) => setState(() => _selectedAssigneeId = id),
            label: 'Assignee',
          ),
          const SizedBox(height: AppSpacing.md),

          // Due date picker
          DatePickerField(
            value: _selectedDueDate,
            onChanged: (date) => setState(() => _selectedDueDate = date),
            label: 'Due Date',
          ),
          const SizedBox(height: AppSpacing.md),

          // Priority selector
          PrioritySelector(
            value: _selectedPriority,
            onChanged: (priority) => setState(() => _selectedPriority = priority),
            label: 'Priority',
          ),
          const SizedBox(height: AppSpacing.lg),

          // Submit button
          AppButton(
            label: widget.submitLabel,
            variant: AppButtonVariant.primary,
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _handleSubmit,
            leadingIcon: const Icon(Icons.add_task),
          ),
        ],
      ),
    );
  }
}

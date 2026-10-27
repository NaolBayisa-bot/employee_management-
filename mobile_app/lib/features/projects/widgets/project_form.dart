// Project form widget.
//
// Form for creating/editing projects with name and description fields,
// validation, and a submit button.

import 'package:flutter/material.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/widgets/app_button.dart';
import 'package:employee_management/shared/widgets/app_text_field.dart';

typedef ProjectFormSubmit = void Function(String name, String description);

class ProjectForm extends StatefulWidget {
  const ProjectForm({
    super.key,
    this.initialName = '',
    this.initialDescription = '',
    this.submitLabel = 'Create Project',
    this.isLoading = false,
    this.onSubmit,
    this.nameFocusNode,
    this.descriptionFocusNode,
    this.fieldErrors,
  });

  final String initialName;
  final String initialDescription;
  final String submitLabel;
  final bool isLoading;
  final ProjectFormSubmit? onSubmit;
  final FocusNode? nameFocusNode;
  final FocusNode? descriptionFocusNode;
  final Map<String, String>? fieldErrors;

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Project name is required';
    }
    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (text.length > 150) {
      return 'Name must not exceed 150 characters';
    }
    // Check for server-side field error
    if (widget.fieldErrors?.containsKey('name') ?? false) {
      return widget.fieldErrors!['name'];
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 2000) {
      return 'Description must not exceed 2000 characters';
    }
    // Check for server-side field error
    if (widget.fieldErrors?.containsKey('description') ?? false) {
      return widget.fieldErrors!['description'];
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          AppTextField(
            controller: _nameController,
            focusNode: widget.nameFocusNode,
            label: 'Project Name',
            hint: 'Enter project name',
            validator: _validateName,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            leadingIcon: const Icon(Icons.folder_outlined, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),

          // Description field
          AppTextField(
            controller: _descriptionController,
            focusNode: widget.descriptionFocusNode,
            label: 'Description',
            hint: 'Enter project description (optional)',
            validator: _validateDescription,
            multiline: true,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            leadingIcon: const Icon(Icons.description_outlined, size: 20),
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Submit button
          AppButton(
            label: widget.submitLabel,
            variant: AppButtonVariant.primary,
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _handleSubmit,
            leadingIcon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
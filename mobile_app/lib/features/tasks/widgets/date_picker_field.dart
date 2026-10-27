// Date picker field widget.
//
// Shows formatted date, opens showDatePicker, has a clear button.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
// ignore: unused_import
import 'package:employee_management/shared/widgets/app_text_field.dart';

class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Due Date',
    this.firstDate,
    this.lastDate,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  static final _dateFormat = DateFormat('MMM d, yyyy');

  Future<void> _pickDate() async {
    final initialDate = widget.value ?? DateTime.now();
    final firstDate =
        widget.firstDate ?? DateTime.now().subtract(const Duration(days: 365));
    final lastDate =
        widget.lastDate ?? DateTime.now().add(const Duration(days: 365 * 5));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surfaceContainer,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: AppColors.surfaceContainer,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      widget.onChanged(picked);
    }
  }

  void _clearDate() {
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
          suffixIcon: widget.value != null
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: _clearDate,
                  tooltip: 'Clear date',
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.primary, width: 2.0),
          ),
          filled: true,
          fillColor: AppColors.glassFill,
        ),
        child: Text(
          widget.value != null
              ? _dateFormat.format(widget.value!)
              : 'Select date',
          style: TextStyle(
            color: widget.value != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

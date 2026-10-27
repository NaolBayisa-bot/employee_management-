import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';

/// A friendly date label with a calendar icon.
///
/// Shows "Today", "Tomorrow", or a formatted date like "Oct 25".
/// Displays in error color when the date is overdue.
class DueDateLabel extends StatelessWidget {
  const DueDateLabel({
    super.key,
    required this.date,
    this.overdue = false,
  });

  final DateTime? date;
  final bool overdue;

  String _formatDate(BuildContext context) {
    if (date == null) return '';

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (date!.isAfter(todayDate.subtract(const Duration(days: 1))) &&
        !date!.isAfter(todayDate)) {
      return 'Today';
    }
    if (date!.isAfter(todayDate) &&
        !date!.isAfter(todayDate.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }

    return DateFormat('MMM d').format(date!);
  }

  @override
  Widget build(BuildContext context) {
    final color = overdue ? AppColors.error : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            _formatDate(context),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
// Member avatar stack widget.
//
// Displays overlapping member avatars with a "+N" overflow indicator.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/avatar.dart';

class MemberAvatarStack extends StatelessWidget {
  const MemberAvatarStack({
    super.key,
    required this.members,
    this.max = 4,
    this.size = AvatarSize.medium,
  });

  final List<ProjectMember> members;
  final int max;
  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayMembers = members.take(max).toList();
    final overflowCount = members.length - max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stack of avatars
        Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < displayMembers.length; i++)
              Positioned(
                left: i * (size.dimension - 8.0).toDouble(),
                child: Avatar(
                  name: displayMembers[i].name,
                  size: size,
                ),
              ),
          ],
        ),
        // Overflow indicator
        if (overflowCount > 0) ...[
          const SizedBox(width: -4),
          Container(
            width: size.dimension,
            height: size.dimension,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '+$overflowCount',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size.fontSize * 0.85,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
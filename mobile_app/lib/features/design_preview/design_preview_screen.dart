// TEMPORARY, remove in Task 24.
//
// Design Preview Gallery showcasing all dark glassmorphic building blocks,
// tokens, components, edge cases, and modal interactions.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../shared/models/project.dart';
import '../../shared/models/task.dart';
import '../../shared/models/user.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/glass_app_bar.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/glass_dialogs.dart';
import '../../shared/widgets/glass_navigation_bar.dart';
import '../../shared/widgets/info_row.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/mono_text.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

/// Design-preview gallery route that displays all design system widgets with
/// sample data, edge cases, and interactive triggers.
class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});

  static const String routeName = '/design-preview';

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  int _navIndex = 0;
  bool _cardPressedCounter = false;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug preview not available in release.')),
      );
    }

    return Scaffold(
      extendBody: true,
      appBar: const GlassAppBar(
        titleText: 'Design System Gallery',
      ),
      bottomNavigationBar: GlassNavigationBar(
        selectedIndex: _navIndex,
        onSelected: (index) => setState(() => _navIndex = index),
        destinations: const [
          GlassNavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Components',
          ),
          GlassNavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: 'Styles',
          ),
          GlassNavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'Modals',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: 100, // accommodate bottom navigation bar
        ),
        children: [
          // 1. Typography & Mono
          const SectionHeader(title: '1. Typography & MonoText'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Small (Space Grotesk)',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Headline Small (Space Grotesk)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Title Large (Space Grotesk)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Body Large (Inter): Clean, modern typography designed for high readability on dark glass backgrounds.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Body Small (Inter, slate secondary)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'MonoText (JetBrains Mono numbers & telemetry):',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MonoText('#TASK-8042'),
                    MonoText('2026-10-24 21:00 UTC'),
                    MonoText('99.98% SLA', color: AppColors.secondary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 2. Buttons
          const SectionHeader(title: '2. AppButton Variants'),
          GlassCard(
            child: Column(
              children: [
                AppButton(
                  label: 'Primary Gradient Button',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    AppSnackBar.showSuccess(context, 'Primary button pressed');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Primary with Leading Icon',
                  variant: AppButtonVariant.primary,
                  leadingIcon: const Icon(Icons.rocket_launch_rounded),
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Secondary Glass Button',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Text Button',
                  variant: AppButtonVariant.text,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                const AppButton(
                  label: 'Loading State Button',
                  isLoading: true,
                  onPressed: null,
                ),
                const SizedBox(height: AppSpacing.md),
                const AppButton(
                  label: 'Disabled Button',
                  onPressed: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 3. Text Fields
          const SectionHeader(title: '3. AppTextField States'),
          GlassCard(
            child: Column(
              children: [
                const AppTextField(
                  label: 'Standard Input',
                  hint: 'Enter your username or email',
                  leadingIcon: Icon(Icons.person_outline),
                ),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(
                  label: 'Password Input (Toggle Visibility)',
                  hint: '••••••••••••',
                  isPassword: true,
                  leadingIcon: Icon(Icons.lock_outline),
                ),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(
                  label: 'Multiline Text Area',
                  hint: 'Describe project requirements and deliverables...',
                  multiline: true,
                ),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(
                  label: 'Input with Validation Error',
                  initialValue: 'invalid-email-address',
                  errorText: 'Please enter a valid company email',
                  leadingIcon: Icon(Icons.mail_outline),
                ),
                const SizedBox(height: AppSpacing.md),
                const AppTextField(
                  label: 'Disabled Input',
                  initialValue: 'Read-only system value',
                  enabled: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 4. Status Chips
          const SectionHeader(title: '4. StatusChip Badges (All Types)'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Status Chips:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusChip.taskStatus(TaskStatus.todo, dot: true),
                    StatusChip.taskStatus(TaskStatus.inProgress, dot: true),
                    StatusChip.taskStatus(TaskStatus.done, dot: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Priority Chips:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusChip.priority(TaskPriority.low),
                    StatusChip.priority(TaskPriority.medium),
                    StatusChip.priority(TaskPriority.high),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Role Chips:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusChip.role(Role.admin),
                    StatusChip.role(Role.manager),
                    StatusChip.role(Role.employee),
                    StatusChip.role(null),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'User Status Chips:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusChip.userStatus(UserStatus.pending),
                    StatusChip.userStatus(UserStatus.active),
                    StatusChip.userStatus(UserStatus.deactivated),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Project Status Chips:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusChip.projectStatus(ProjectStatus.active),
                    StatusChip.projectStatus(ProjectStatus.archived),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 5. Avatars & Edge Cases
          const SectionHeader(title: '5. Avatar Initials & Sizes'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Avatar(name: 'John Doe', size: AvatarSize.small),
                        SizedBox(height: AppSpacing.xs),
                        Text('Small (32)', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    Column(
                      children: [
                        Avatar(name: 'John Doe', size: AvatarSize.medium),
                        SizedBox(height: AppSpacing.xs),
                        Text('Medium (44)', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    Column(
                      children: [
                        Avatar(name: 'John Doe', size: AvatarSize.large),
                        SizedBox(height: AppSpacing.xs),
                        Text('Large (64)', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Edge Case Name Handling:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Avatar(name: '', size: AvatarSize.medium),
                        SizedBox(height: AppSpacing.xs),
                        Text('Empty ("")', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    Column(
                      children: [
                        Avatar(name: 'Alice', size: AvatarSize.medium),
                        SizedBox(height: AppSpacing.xs),
                        Text('Single ("Alice")', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    Column(
                      children: [
                        Avatar(
                          name: 'Alexandria Bartholomew Demetrius',
                          size: AvatarSize.medium,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text('Very Long', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 6. Glass Cards (Blur true vs Blur false, Tap feedback)
          const SectionHeader(title: '6. GlassCard Interaction & Blur Modes'),
          GlassCard(
            blur: true,
            onTap: () {
              setState(() {
                _cardPressedCounter = !_cardPressedCounter;
                _tapCount++;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interactive Card (blur: true)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Tap to test pressed brightening. Tapped $_tapCount times.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const GlassCard(
            blur: false,
            child: Row(
              children: [
                Icon(Icons.blur_off_rounded, color: AppColors.secondary),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card with blur: false',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Optimized for dense ListViews where backdrop filter is omitted for maximum frame rate.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 7. InfoRow & SectionHeader
          const SectionHeader(
            title: '7. InfoRow Key-Value Details',
            trailing: Icon(Icons.info_outline, size: 18),
          ),
          GlassCard(
            child: Column(
              children: [
                const InfoRow(
                  icon: Icons.person_outline,
                  label: 'Project Owner',
                  value: 'Sarah Connor',
                ),
                const Divider(),
                const InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due Date',
                  value: '2026-11-15',
                  isMonospace: true,
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.flag_outlined,
                  label: 'Current Status',
                  value: '',
                  valueWidget: StatusChip.taskStatus(TaskStatus.inProgress),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 8. Feedback & State Views
          const SectionHeader(title: '8. Feedback & Skeleton Views'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shimmer-style Skeleton Placeholders (Pure Flutter):',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.sm),
                const SkeletonPlaceholder(width: 140, height: 16),
                const SizedBox(height: AppSpacing.sm),
                const SkeletonPlaceholder(width: double.infinity, height: 12),
                const SizedBox(height: AppSpacing.xs),
                const SkeletonPlaceholder(width: 220, height: 12),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Mini ErrorView:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.sm),
                ErrorView(
                  title: 'Connection Lost',
                  message: 'Unable to reach backend gateway. Check network.',
                  onRetry: () {
                    AppSnackBar.showSuccess(context, 'Retried connection!');
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Mini EmptyView:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.sm),
                EmptyView(
                  icon: Icons.inbox_outlined,
                  title: 'No Pending Tasks',
                  subtitle: 'You are completely caught up with your sprint assignments.',
                  action: AppButton(
                    label: 'Create Task',
                    fullWidth: false,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 9. Dialogs, Bottom Sheet & SnackBars
          const SectionHeader(title: '9. Dialogs, Bottom Sheets & SnackBars'),
          GlassCard(
            child: Column(
              children: [
                AppButton(
                  label: 'Open Glass Confirm Dialog',
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    final confirmed = await showConfirmDialog(
                      context: context,
                      title: 'Approve User Request',
                      message: 'Are you sure you want to approve this user as MANAGER?',
                      confirmLabel: 'Approve',
                    );
                    if (context.mounted && confirmed == true) {
                      AppSnackBar.showSuccess(context, 'User approved successfully!');
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Open Destructive Confirm Dialog',
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    final confirmed = await showConfirmDialog(
                      context: context,
                      title: 'Deactivate Account',
                      message: 'This user will be revoked of all system access immediately.',
                      confirmLabel: 'Deactivate',
                      destructive: true,
                    );
                    if (context.mounted && confirmed == true) {
                      AppSnackBar.showError(context, 'Account was deactivated.');
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Open Glass Bottom Sheet',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    showGlassBottomSheet(
                      context: context,
                      builder: (sheetContext) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filter Projects',
                                style: Theme.of(sheetContext).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Text(
                                'Select visibility and role filters to adjust project results.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AppButton(
                                label: 'Apply Filters',
                                onPressed: () => Navigator.of(sheetContext).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Show Success SnackBar',
                        variant: AppButtonVariant.text,
                        onPressed: () {
                          AppSnackBar.showSuccess(context, 'Changes saved successfully');
                        },
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: 'Show Error SnackBar',
                        variant: AppButtonVariant.text,
                        onPressed: () {
                          AppSnackBar.showError(context, 'Failed to authenticate');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

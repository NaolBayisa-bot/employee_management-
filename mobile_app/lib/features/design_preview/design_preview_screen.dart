// TEMPORARY, remove in Task 24.
//
// Design Preview Gallery showcasing all dark glassmorphic building blocks,
// tokens, components, edge cases, and modal interactions.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/shared/models/dashboard_stats.dart';

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

import 'package:mobile_app/features/tasks/widgets/due_date_label.dart';
import 'package:mobile_app/features/tasks/widgets/priority_badge.dart';
import 'package:mobile_app/features/tasks/widgets/task_card.dart';
import 'package:mobile_app/features/tasks/widgets/assignee_picker.dart';
import 'package:mobile_app/features/tasks/widgets/date_picker_field.dart';
import 'package:mobile_app/features/tasks/widgets/priority_selector.dart';
import 'package:mobile_app/features/tasks/widgets/task_form.dart';
import 'package:mobile_app/features/admin/widgets/stat_card.dart';
import 'package:mobile_app/features/admin/widgets/stats_grid.dart';
import 'package:mobile_app/features/admin/widgets/pending_user_tile.dart';

import '../auth/widgets/auth_header.dart';
import '../auth/widgets/status_message_view.dart';
import '../projects/widgets/candidate_tile.dart';
import '../projects/widgets/member_avatar_stack.dart';
import '../projects/widgets/member_tile.dart';
import '../projects/widgets/project_card.dart';
import '../projects/widgets/project_form.dart';
import '../projects/widgets/project_status_filter.dart';
import '../tasks/widgets/task_list_tile.dart';

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
      appBar: const GlassAppBar(titleText: 'Design System Gallery'),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                const AppButton(label: 'Disabled Button', onPressed: null),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                        Text(
                          'Single ("Alice")',
                          style: TextStyle(fontSize: 11),
                        ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                      AppSnackBar.showSuccess(
                        context,
                        'User approved successfully!',
                      );
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
                      AppSnackBar.showError(
                        context,
                        'Account was deactivated.',
                      );
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
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Text(
                                'Select visibility and role filters to adjust project results.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AppButton(
                                label: 'Apply Filters',
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
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
                          AppSnackBar.showSuccess(
                            context,
                            'Changes saved successfully',
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: 'Show Error SnackBar',
                        variant: AppButtonVariant.text,
                        onPressed: () {
                          AppSnackBar.showError(
                            context,
                            'Failed to authenticate',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: '10. AuthHeader'),
          GlassCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  const AuthHeader(
                    icon: Icons.person_outline,
                    title: 'Welcome Back',
                    subtitle: 'Enter your email to continue.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: '11. StatusMessageView'),
          GlassCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waiting for Approval (warning icon)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatusMessageView(
                    icon: Icons.hourglass_top_rounded,
                    title: 'Awaiting Approval',
                    message:
                        'Your account is pending admin approval. '
                        'You will be able to access the app once an admin activates your account.',
                    iconColor: AppColors.warning,
                    iconBackgroundColor: AppColors.warningFill,
                    actions: [
                      AppButton(
                        label: 'Check Again',
                        onPressed: () {},
                        variant: AppButtonVariant.primary,
                      ),
                      AppButton(
                        label: 'Logout',
                        onPressed: () {},
                        variant: AppButtonVariant.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Deactivated Account (error icon)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatusMessageView(
                    icon: Icons.block_rounded,
                    title: 'Account Deactivated',
                    message:
                        'Your account has been deactivated. '
                        'Please contact support if you believe this is a mistake.',
                    iconColor: AppColors.error,
                    iconBackgroundColor: AppColors.errorFill,
                    actions: [
                      AppButton(
                        label: 'Logout',
                        onPressed: () {},
                        variant: AppButtonVariant.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Custom Icon/Colors Example',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatusMessageView(
                    icon: Icons.check_circle_outline,
                    title: 'Success State',
                    message:
                        'This shows a custom success icon with green colors.',
                    iconColor: AppColors.success,
                    iconBackgroundColor: AppColors.successFill,
                    actions: [
                      AppButton(
                        label: 'Continue',
                        onPressed: () {},
                        variant: AppButtonVariant.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 10. Project Feature Widgets
          const SectionHeader(title: '10. Project Feature Widgets'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ProjectCard — normal active project',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectCard(
                  project: Project(
                    id: 'p1',
                    name: 'Website Redesign',
                    description: 'Complete overhaul of the company website with modern design system, improved accessibility, and responsive layouts.',
                    status: ProjectStatus.active,
                    owner: UserRef(id: 'u1', name: 'Alice Johnson'),
                    memberCount: 5,
                    taskCount: 12,
                    createdAt: DateTime(2024, 1, 15),
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'ProjectCard — archived project with long name and empty description',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectCard(
                  project: Project(
                    id: 'p2',
                    name: 'Legacy System Migration to Cloud Infrastructure Platform',
                    description: '',
                    status: ProjectStatus.archived,
                    owner: UserRef(id: 'u2', name: 'Bob Smith'),
                    memberCount: 0,
                    taskCount: 0,
                    createdAt: DateTime(2023, 6, 10),
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'ProjectCard — zero members and zero tasks',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectCard(
                  project: Project(
                    id: 'p3',
                    name: 'Internal Tools',
                    description: 'Small utility project for internal automation scripts.',
                    status: ProjectStatus.active,
                    owner: UserRef(id: 'u3', name: 'Carol White'),
                    memberCount: 0,
                    taskCount: 0,
                    createdAt: DateTime(2024, 3, 1),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MemberTile — various roles',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Column(
                  children: [
                    MemberTile(
                      member: ProjectMember(
                        id: 'm1',
                        name: 'Alice Johnson',
                        role: Role.admin,
                      ),
                      trailing: const Icon(Icons.more_vert),
                    ),
                    const Divider(
                      color: AppColors.divider,
                      height: AppSpacing.md,
                    ),
                    MemberTile(
                      member: ProjectMember(
                        id: 'm2',
                        name: 'Bob Smith',
                        role: Role.manager,
                      ),
                      trailing: const Icon(Icons.more_vert),
                    ),
                    const Divider(
                      color: AppColors.divider,
                      height: AppSpacing.md,
                    ),
                    MemberTile(
                      member: ProjectMember(
                        id: 'm3',
                        name: 'Carol White',
                        role: Role.employee,
                      ),
                      trailing: const Icon(Icons.more_vert),
                    ),
                    const Divider(
                      color: AppColors.divider,
                      height: AppSpacing.md,
                    ),
                    MemberTile(
                      member: ProjectMember(
                        id: 'm4',
                        name: 'David Brown',
                        role: null,
                      ),
                      trailing: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CandidateTile — not a member (Add button)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CandidateTile(
                  candidate: Candidate(
                    id: 'u1',
                    name: 'Alice Johnson',
                    role: Role.manager,
                  ),
                  isMember: false,
                  onAdd: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'CandidateTile — already a member (Member label)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CandidateTile(
                  candidate: Candidate(
                    id: 'u2',
                    name: 'Bob Smith',
                    role: Role.employee,
                  ),
                  isMember: true,
                  onAdd: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'CandidateTile — loading state',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CandidateTile(
                  candidate: Candidate(
                    id: 'u3',
                    name: 'Carol White',
                    role: Role.employee,
                  ),
                  isMember: false,
                  onAdd: () {},
                  isLoading: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MemberAvatarStack — with overflow (+N)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MemberAvatarStack(
                  members: [
                    ProjectMember(
                      id: 'm1',
                      name: 'Alice Johnson',
                      role: Role.admin,
                    ),
                    ProjectMember(
                      id: 'm2',
                      name: 'Bob Smith',
                      role: Role.manager,
                    ),
                    ProjectMember(
                      id: 'm3',
                      name: 'Carol White',
                      role: Role.employee,
                    ),
                    ProjectMember(
                      id: 'm4',
                      name: 'David Brown',
                      role: Role.employee,
                    ),
                    ProjectMember(
                      id: 'm5',
                      name: 'Eve Davis',
                      role: Role.employee,
                    ),
                    ProjectMember(
                      id: 'm6',
                      name: 'Frank Miller',
                      role: Role.employee,
                    ),
                    ProjectMember(
                      id: 'm7',
                      name: 'Grace Wilson',
                      role: Role.employee,
                    ),
                  ],
                  max: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'MemberAvatarStack — exactly at max (4)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MemberAvatarStack(
                  members: [
                    ProjectMember(
                      id: 'm1',
                      name: 'Alice Johnson',
                      role: Role.admin,
                    ),
                    ProjectMember(
                      id: 'm2',
                      name: 'Bob Smith',
                      role: Role.manager,
                    ),
                    ProjectMember(
                      id: 'm3',
                      name: 'Carol White',
                      role: Role.employee,
                    ),
                    ProjectMember(
                      id: 'm4',
                      name: 'David Brown',
                      role: Role.employee,
                    ),
                  ],
                  max: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'MemberAvatarStack — empty',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MemberAvatarStack(members: [], max: 4),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ProjectForm — empty (validation errors)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectForm(onSubmit: (name, desc) {}),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'ProjectForm — pre-filled with short name (validation error)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectForm(
                  initialName: 'A',
                  initialDescription: 'Short',
                  submitLabel: 'Update Project',
                  onSubmit: (name, desc) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'ProjectForm — loading state',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectForm(
                  initialName: 'Website Redesign',
                  initialDescription: 'Complete overhaul of the company website with modern design system.',
                  submitLabel: 'Saving...',
                  isLoading: true,
                  onSubmit: (name, desc) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ProjectStatusFilter — All selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectStatusFilter(selected: null, onChanged: (v) {}),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'ProjectStatusFilter — Active selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectStatusFilter(
                  selected: ProjectStatus.active,
                  onChanged: (v) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'ProjectStatusFilter — Archived selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProjectStatusFilter(
                  selected: ProjectStatus.archived,
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
          //
          // 11. Task Feature Widgets
          SectionHeader(title: '11. Task Feature Widgets'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TaskListTile — with assignee',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TaskListTile(
                  task: Task(
                    id: 't1',
                    title: 'Design new dashboard layout',
                    status: TaskStatus.todo,
                    priority: TaskPriority.high,
                    projectId: 'p1',
                    assignee: UserRef(id: 'u1', name: 'Alice Johnson'),
                    createdAt: DateTime(2024, 1, 15),
                  ),
                  onTap: () {},
                ),
                const Divider(color: AppColors.divider, height: AppSpacing.md),
                const Text(
                  'TaskListTile — unassigned with long title',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TaskListTile(
                  task: Task(
                    id: 't2',
                    title: 'This is a very long task title that should be truncated properly in the UI',
                    status: TaskStatus.inProgress,
                    priority: TaskPriority.medium,
                    projectId: 'p1',
                    assignee: null,
                    createdAt: DateTime(2024, 1, 16),
                  ),
                  onTap: () {},
                ),
                const Divider(color: AppColors.divider, height: AppSpacing.md),
                const Text(
                  'TaskListTile — completed task',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TaskListTile(
                  task: Task(
                    id: 't3',
                    title: 'Fix login bug',
                    status: TaskStatus.done,
                    priority: TaskPriority.low,
                    projectId: 'p1',
                    assignee: UserRef(id: 'u2', name: 'Bob Smith'),
                    createdAt: DateTime(2024, 1, 10),
                  ),
                  onTap: () {},
                ),
                const Divider(color: AppColors.divider, height: AppSpacing.md),
                const Text(
                  'DueDateLabel — with date',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DueDateLabel(date: DateTime(2024, 10, 25), overdue: false),
                const SizedBox(height: AppSpacing.md),
                DueDateLabel(
                  date: DateTime.now().add(const Duration(days: 1)),
                  overdue: false,
                ),
                const SizedBox(height: AppSpacing.md),
                DueDateLabel(
                  date: DateTime.now().add(const Duration(days: -1)),
                  overdue: true,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'PriorityBadge — low / medium / high',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    PriorityBadge(priority: TaskPriority.low),
                    const SizedBox(width: AppSpacing.sm),
                    PriorityBadge(priority: TaskPriority.medium),
                    const SizedBox(width: AppSpacing.sm),
                    PriorityBadge(priority: TaskPriority.high),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'TaskCard — with all fields',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TaskCard(
                  task: Task(
                    id: 't4',
                    title: 'Design new dashboard layout',
                    status: TaskStatus.todo,
                    priority: TaskPriority.high,
                    projectId: 'p1',
                    assignee: UserRef(id: 'u1', name: 'Alice Johnson'),
                    createdAt: DateTime(2024, 1, 15),
                    dueDate: DateTime(2024, 10, 20),
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                TaskCard(
                  task: Task(
                    id: 't5',
                    title: 'Fix login bug',
                    status: TaskStatus.done,
                    priority: TaskPriority.low,
                    projectId: 'p1',
                    assignee: UserRef(id: 'u2', name: 'Bob Smith'),
                    createdAt: DateTime(2024, 1, 10),
                    dueDate: null,
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                TaskCard(
                  task: Task(
                    id: 't6',
                    title: 'This is a very long task title that should be truncated properly in the UI and wrap to multiple lines if needed',
                    status: TaskStatus.inProgress,
                    priority: TaskPriority.medium,
                    projectId: 'p1',
                    assignee: null,
                    createdAt: DateTime(2024, 1, 16),
                    dueDate: DateTime(2024, 11, 1),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // ===== NEW TASK FORM WIDGETS (Task 20) =====
          SectionHeader(title: 'Task Form Widgets (Task 20)'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AssigneePicker — empty',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AssigneePicker(
                  members: [
                    ProjectMember(
                      id: 'm1',
                      name: 'Alice Johnson',
                      role: Role.admin,
                    ),
                    ProjectMember(
                      id: 'm2',
                      name: 'Bob Smith',
                      role: Role.manager,
                    ),
                    ProjectMember(
                      id: 'm3',
                      name: 'Carol White',
                      role: Role.employee,
                    ),
                  ],
                  selectedId: null,
                  onChanged: (v) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'AssigneePicker — with selection',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AssigneePicker(
                  members: [
                    ProjectMember(
                      id: 'm1',
                      name: 'Alice Johnson',
                      role: Role.admin,
                    ),
                    ProjectMember(
                      id: 'm2',
                      name: 'Bob Smith',
                      role: Role.manager,
                    ),
                    ProjectMember(
                      id: 'm3',
                      name: 'Carol White',
                      role: Role.employee,
                    ),
                  ],
                  selectedId: 'm2',
                  onChanged: (v) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'DatePickerField — empty',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DatePickerField(value: null, onChanged: (v) {}),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'DatePickerField — with date',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DatePickerField(
                  value: DateTime(2024, 10, 25),
                  onChanged: (v) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'PrioritySelector — Low selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrioritySelector(value: TaskPriority.low, onChanged: (v) {}),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'PrioritySelector — Medium selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrioritySelector(value: TaskPriority.medium, onChanged: (v) {}),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'PrioritySelector — High selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrioritySelector(value: TaskPriority.high, onChanged: (v) {}),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'TaskForm — empty (validation errors)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TaskForm(
                  members: [
                    ProjectMember(
                      id: 'm1',
                      name: 'Alice Johnson',
                      role: Role.admin,
                    ),
                    ProjectMember(
                      id: 'm2',
                      name: 'Bob Smith',
                      role: Role.manager,
                    ),
                    ProjectMember(
                      id: 'm3',
                      name: 'Carol White',
                      role: Role.employee,
                    ),
                  ],
                  onSubmit: (v) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'TaskForm — prefilled from Task',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TaskForm(
                  initialTask: Task(
                    id: 't1',
                    title: 'Design new dashboard',
                    description:
                        'Create a new dashboard layout with dark theme',
                    status: TaskStatus.todo,
                    priority: TaskPriority.high,
                    projectId: 'p1',
                    assignee: UserRef(id: 'm2', name: 'Bob Smith'),
                    createdAt: DateTime(2024, 1, 15),
                    dueDate: DateTime(2024, 10, 30),
                  ),
                  members: [
                    ProjectMember(
                      id: 'm1',
                      name: 'Alice Johnson',
                      role: Role.admin,
                    ),
                    ProjectMember(
                      id: 'm2',
                      name: 'Bob Smith',
                      role: Role.manager,
                    ),
                    ProjectMember(
                      id: 'm3',
                      name: 'Carol White',
                      role: Role.employee,
                    ),
                  ],
                  submitLabel: 'Update Task',
                  onSubmit: (v) {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'TaskForm — loading state',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TaskForm(
                  initialTask: Task(
                    id: 't2',
                    title: 'Fix login bug',
                    description: 'Users cannot login with Google OAuth',
                    status: TaskStatus.inProgress,
                    priority: TaskPriority.medium,
                    projectId: 'p1',
                    assignee: UserRef(id: 'm1', name: 'Alice Johnson'),
                    createdAt: DateTime(2024, 1, 10),
                    dueDate: DateTime(2024, 10, 20),
                  ),
                  members: [
                    ProjectMember(
                      id: 'm1',
                      name: 'Alice Johnson',
                      role: Role.admin,
                    ),
                    ProjectMember(
                      id: 'm2',
                      name: 'Bob Smith',
                      role: Role.manager,
                    ),
                    ProjectMember(
                      id: 'm3',
                      name: 'Carol White',
                      role: Role.employee,
                    ),
                  ],
                  submitLabel: 'Saving...',
                  isLoading: true,
                  onSubmit: (v) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 12. Admin Feature Widgets (Task 22)
          const SectionHeader(title: '12. Admin Feature Widgets (Task 22)'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'StatCard — normal',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Users',
                        value: 127,
                        icon: Icons.people_outline,
                        accent: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        label: 'Pending',
                        value: 8,
                        icon: Icons.hourglass_empty_outlined,
                        accent: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'StatCard — with accent colors',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Success',
                        value: 42,
                        icon: Icons.check_circle_outline,
                        accent: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        label: 'Error',
                        value: 3,
                        icon: Icons.error_outline,
                        accent: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'StatCard — loading/skeleton',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: StatCard.loading()),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: StatCard.loading()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'StatsGrid — with sample data',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                StatsGrid(
                  stats: DashboardStats(
                    totalUsers: 127,
                    pendingUsers: 8,
                    activeProjects: 12,
                    openTasks: 45,
                    doneTasks: 89,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'StatsGrid — empty/zero state',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                StatsGrid(stats: DashboardStats()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PendingUserTile — normal',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PendingUserTile(
                  user: User(
                    id: 'u1',
                    name: 'John Doe',
                    email: 'john.doe@example.com',
                    role: null,
                    status: UserStatus.pending,
                    createdAt: DateTime(2024, 1, 15),
                  ),
                  selectedRole: Role.employee,
                  onRoleChanged: (role) {},
                  onApprove: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'PendingUserTile — Manager role selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PendingUserTile(
                  user: User(
                    id: 'u2',
                    name: 'Jane Smith',
                    email: 'jane.smith@example.com',
                    role: null,
                    status: UserStatus.pending,
                    createdAt: DateTime(2024, 2, 20),
                  ),
                  selectedRole: Role.manager,
                  onRoleChanged: (role) {},
                  onApprove: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'PendingUserTile — loading state',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PendingUserTile(
                  user: User(
                    id: 'u3',
                    name: 'Bob Wilson',
                    email: 'bob.wilson@example.com',
                    role: null,
                    status: UserStatus.pending,
                    createdAt: DateTime(2024, 3, 10),
                  ),
                  selectedRole: Role.employee,
                  onRoleChanged: (role) {},
                  onApprove: () {},
                  loading: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add members screen.
//
// Allows MANAGER/ADMIN to search eligible users and add them to a project.
// Debounced search (400 ms) calls GET /projects/candidates.
// Candidates already in the project are marked as "Member" and cannot be
// added again. Adding shows a success snackbar and refreshes the project
// detail's member list.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/network/api_exception.dart';
import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/projects/data/project_repository.dart';
import 'package:mobile_app/features/projects/providers/project_provider.dart';
import 'package:mobile_app/features/projects/widgets/candidate_tile.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/app_snack_bar.dart';
import 'package:mobile_app/shared/widgets/app_text_field.dart';
import 'package:mobile_app/shared/widgets/empty_view.dart';
import 'package:mobile_app/shared/widgets/error_view.dart';
import 'package:mobile_app/shared/widgets/loading_view.dart';

class AddMembersScreen extends ConsumerStatefulWidget {
  const AddMembersScreen({super.key, required this.projectId});

  final String projectId;

  static const String routeName = '/projects/:id/members/add';

  @override
  ConsumerState<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends ConsumerState<AddMembersScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;

  /// The currently displayed search term (empty string when no filter).
  String _searchTerm = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Debounced search: after 400 ms of no typing, notify the provider.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _searchTerm = value.trim();
    });
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      // Touching the candidatesProvider family forces a refetch with the
      // new [search] argument.
      ref.read(candidatesProvider(_searchTerm).future);
    });
  }

  /// Adds [candidate] to the project.
  Future<void> _addMember(Candidate candidate) async {
    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.addMember(widget.projectId, candidate.id);

      if (!mounted) return;

      // Invalidate the project provider so the detail screen's member list
      // is refreshed when the user navigates back.
      ref.invalidate(projectProvider(widget.projectId));
      // Also invalidate the candidates provider so "Add" buttons flip to
      // "Member" labels on refresh.
      ref.invalidate(candidatesProvider(_searchTerm));

      AppSnackBar.showSuccess(context, '${candidate.name} added to project');
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Failed to add member: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager ||
        user?.role == Role.admin;

    // Redirect non-manager/admin users
    if (!isManagerOrAdmin) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Access Denied',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Only managers and admins can add members.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Back to Project',
                  variant: AppButtonVariant.primary,
                  onPressed: () =>
                      context.go('/projects/${widget.projectId}'),
                  fullWidth: false,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final projectAsync = ref.watch(projectProvider(widget.projectId));
    final candidatesAsync = ref.watch(candidatesProvider(_searchTerm));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/projects/${widget.projectId}'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: AppTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                label: 'Search users',
                hint: 'Search by name',
                leadingIcon: const Icon(Icons.search, size: 20),
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
              ),
            ),
            // Candidates list / states
            Expanded(
              child: projectAsync.when(
                loading: () => const LoadingView(message: 'Loading project...'),
                error: (error, stackTrace) => ErrorView(
                  title: 'Failed to load project',
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(projectProvider(widget.projectId)),
                ),
                data: (project) => candidatesAsync.when(
                  loading: () => const LoadingView(
                    message: 'Loading candidates...',
                  ),
                  error: (error, stackTrace) => ErrorView(
                    title: 'Failed to load candidates',
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(candidatesProvider(_searchTerm)),
                  ),
                  data: (candidates) {
                    final memberIds = project.members.map((m) => m.id).toSet();
                    final eligible = candidates
                        .where((c) => c.role != null)
                        .toList();

                    if (eligible.isEmpty) {
                      return EmptyView(
                        icon: Icons.group_off_outlined,
                        title: _searchTerm.isEmpty
                            ? 'No candidates found'
                            : 'No matching candidates',
                        subtitle: _searchTerm.isEmpty
                            ? 'There are no eligible users to add.'
                            : 'Try adjusting your search.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: eligible.length,
                      itemBuilder: (context, index) {
                        final candidate = eligible[index];
                        final alreadyMember = memberIds.contains(candidate.id);
                        return CandidateTile(
                          candidate: candidate,
                          isMember: alreadyMember,
                          onAdd: () => _addMember(candidate),
                          isLoading: false,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
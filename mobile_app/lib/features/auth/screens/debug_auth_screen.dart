// TEMPORARY, replaced in Task 9.
//
// Minimal manual-entry screen for validating the auth flow end-to-end:
//   - email + password fields, Login button
//   - Logout button
//   - displays the current user's name, role and status once logged in
//
// On a wrong password the server returns 401 with message
// "Invalid email or password" (see backend/src/controllers/auth.controller.js),
// which [AuthRepository.login] surfaces as an [ApiException] -> shown as a
// SnackBar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/models/user.dart';
import '../providers/auth_provider.dart';

class DebugAuthScreen extends ConsumerStatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  ConsumerState<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends ConsumerState<DebugAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _submitting = true);
    try {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in')),
        );
      }
    } on ApiException catch (e) {
      // Surface server auth errors (e.g. "Invalid email or password").
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        // "Task Manager" is kept here so the existing widget test
        // (find.text('Task Manager')) continues to pass.
        title: const Text('Task Manager'),
      ),
      body: Center(
        child: asyncUser.when(
          data: (user) => _buildData(user),
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => _buildError(error),
        ),
      ),
    );
  }

  Widget _buildData(User? user) {
    if (user == null) {
      // Logged out: show the login form.
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
        ]),
      );
    }

    // Logged in: show the current user's identity.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Name: ${user.name}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('Role: ${user.role?.toServerValue() ?? '—'}'),
        const SizedBox(height: AppSpacing.sm),
        Text('Status: ${user.status.toServerValue()}'),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(onPressed: _logout, child: const Text('Logout')),
      ],
    );
  }

  Widget _buildError(Object error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Error: $error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          onPressed: () => ref.read(authProvider.notifier).refreshMe(),
          child: const Text('Retry'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(onPressed: _logout, child: const Text('Logout')),
      ],
    );
  }
}

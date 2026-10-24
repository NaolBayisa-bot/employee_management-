// TEMPORARY, replaced in Task 9.
//
// Login entry point. Built from the shared design-system widgets
// (AuthHeader, AppTextField, AppButton) per Task 7. Replaces the hand-rolled
// debug login from Task 4. Until Task 9, a successful login switches to a
// temporary logged-in view (name/role/status + Logout) instead of navigating
// to the real app shell.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/network/api_exception.dart';
import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/auth/widgets/auth_header.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/app_snack_bar.dart';
import 'package:mobile_app/shared/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Submits the form: runs validation, dismisses the keyboard, calls login,
  /// and surfaces any server error inline.
  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    // Dismiss the keyboard on submit.
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // authProvider state is now AsyncData(user); the UI swaps to the
      // temporary logged-in view automatically via ref.watch below.
    } on ApiException catch (e) {
      // Wrong password (401) and deactivated (403) both surface here as an
      // inline message; neither triggers an auto-logout (login is an auth route
      // and is excluded from the unauthorized interceptor).
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Scroll so the form never overflows when the keyboard is open on a
          // small screen.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: user == null ? _buildLoginForm() : _buildLoggedIn(user),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            key: const Key('email_field'),
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) {
                return 'Email is required';
              }
              // "invalid" email (no @) -> validator message, no request sent.
              if (!value.contains(RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$'))) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('password_field'),
            controller: _passwordController,
            label: 'Password',
            isPassword: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          // Inline server error area.
          if (_serverError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                _serverError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
          AppButton(
            label: 'Login',
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {
              // Registration opens in Task 9; surface a friendly placeholder now
              // so the button is not an inert no-op.
              AppSnackBar.showSuccess(context, 'Registration is not available yet.');
            },
            child: Text(
              'Create account',
              style: GoogleFonts.roboto(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedIn(User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: Icons.check_circle_outline,
          title: 'Logged in',
          subtitle: 'You have a valid session.',
        ),
        const SizedBox(height: AppSpacing.xl),
        _info('Name', user.name),
        const SizedBox(height: AppSpacing.sm),
        _info('Role', user.role?.toServerValue() ?? '—'),
        const SizedBox(height: AppSpacing.sm),
        _info('Status', user.status.toServerValue()),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Logout',
          variant: AppButtonVariant.secondary,
          onPressed: ref.read(authProvider.notifier).logout,
        ),
      ],
    );
  }

  Widget _info(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
        ],
      );
}

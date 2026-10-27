// Login entry point. Built from the shared design-system widgets
// (AuthHeader, AppTextField, AppButton) per Task 7. Replaces the hand-rolled
// debug login from Task 4. Navigation is handled by go_router (Task 9).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/network/api_exception.dart';
import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/auth/widgets/auth_header.dart';
import 'package:employee_management/shared/widgets/app_button.dart';
import 'package:employee_management/shared/widgets/app_text_field.dart';

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
      // authProvider state is now AsyncData(user); go_router redirect will
      // navigate to the appropriate screen based on user status.
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Scroll so the form never overflows when the keyboard is open on a
          // small screen.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: _buildLoginForm(),
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
          const AuthHeader(
            icon: Icons.lock_rounded,
            title: 'Welcome',
            subtitle: 'Sign in to continue',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            key: const Key('email_field'),
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
            onPressed: () => context.push('/register'),
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
}

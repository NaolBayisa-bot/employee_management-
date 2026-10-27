// Register screen.
//
// Built from the shared design-system widgets (AuthHeader, AppTextField, AppButton)
// per Task 8. Navigation uses go_router (Task 9).

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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _serverError;
  Map<String, String>? _fieldErrors;
  bool _registrationSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Name must be at least 2 characters';
    if (v.length > 100) return 'Name must be at most 100 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (v.length > 72) return 'Password must be at most 72 characters';
    return null;
  }

  String? _validateConfirm(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _serverError = null;
      _fieldErrors = null;
    });
    try {
      await ref.read(authProvider.notifier).register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _registrationSuccess = true);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        setState(() => _serverError = 'Email already registered');
      } else if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
        setState(() {
          _fieldErrors = e.fieldErrors;
          _serverError = e.message;
        });
      } else {
        setState(() => _serverError = e.message);
      }
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: _registrationSuccess ? _buildSuccessView() : _buildRegisterForm(),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            icon: Icons.person_add_outlined,
            title: 'Create account',
            subtitle: 'Register to get started',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            key: const Key('name_field'),
            controller: _nameController,
            label: 'Name',
            hint: '2–100 characters',
            textInputAction: TextInputAction.next,
            validator: _validateName,
            errorText: _fieldErrors?['name'],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('email_field'),
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            errorText: _fieldErrors?['email'],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('password_field'),
            controller: _passwordController,
            label: 'Password',
            hint: '8–72 characters',
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: _validatePassword,
            errorText: _fieldErrors?['password'],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('confirm_field'),
            controller: _confirmController,
            label: 'Confirm password',
            isPassword: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: _validateConfirm,
            errorText: _fieldErrors?['confirmPassword'] ?? _fieldErrors?['confirm'],
          ),
          const SizedBox(height: AppSpacing.md),
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
            label: 'Register',
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Already have an account? Login',
              style: GoogleFonts.roboto(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: Icons.check_circle_outline,
          title: 'Registration successful',
          subtitle: '',
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'An admin must approve your account before you can sign in.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Back to Login',
          variant: AppButtonVariant.primary,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Text field featuring glass fill, light border, primary focus border with soft glow,
/// password obscurity toggle, multiline support, and error state.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.multiline = false,
    this.errorText,
    this.onChanged,
    this.leadingIcon,
    this.trailing,
    this.enabled = true,
    this.focusNode,
    this.initialValue,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool multiline;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? leadingIcon;
  final Widget? trailing;
  final bool enabled;
  final FocusNode? focusNode;
  final String? initialValue;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget = widget.trailing;

    if (widget.isPassword) {
      trailingWidget = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: _hasFocus && !hasError
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: _focusNode,
        enabled: widget.enabled,
        obscureText: _obscureText,
        keyboardType:
            widget.multiline ? TextInputType.multiline : widget.keyboardType,
        maxLines: widget.multiline ? 4 : 1,
        minLines: widget.multiline ? 3 : 1,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          errorText: widget.errorText,
          prefixIcon: widget.leadingIcon,
          suffixIcon: trailingWidget,
        ),
      ),
    );
  }
}

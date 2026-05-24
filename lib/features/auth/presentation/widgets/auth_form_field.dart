import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
    this.enabled = true,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          enabled: enabled,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AuthColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade300 : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade400 : AuthColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

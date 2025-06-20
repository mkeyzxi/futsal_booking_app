// lib/views/common_widgets/custom_text_field.dart (Diperbarui)
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines; // <--- TAMBAHKAN INI

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines =
        1, // <--- TAMBAHKAN INI (default 1, bisa jadi null jika ingin multi-line tanpa batas)
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines, // <--- TERUSKAN KE TextFormField DI SINI
      style: AppStyles.bodyTextStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.smallTextStyle.copyWith(color: Colors.grey[600]),
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: AppStyles.primaryColor)
                : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
          borderSide: const BorderSide(color: AppStyles.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
          borderSide: const BorderSide(color: AppStyles.errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
          borderSide: const BorderSide(color: AppStyles.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

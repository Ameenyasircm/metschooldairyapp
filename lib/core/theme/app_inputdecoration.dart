import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_radius.dart';

class AppInputDecoration {
  static InputDecoration textField({
    required String label,
    required ValueNotifier<bool> obscureNotifier,
    String? hint, bool showObscure=false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorStyle: AppTypography.caption.copyWith(
          color: AppColors.red,
          fontWeight:FontWeight.w500
      ),
      suffixIcon: showObscure?ValueListenableBuilder<bool>(
          valueListenable: obscureNotifier,
          builder: (context, obscureText, _) {
            return IconButton(
              icon: Icon(
                size: 20,color: AppColors.grey5E,
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                obscureNotifier.value = !obscureText;
              },
            );
          }
      ):null,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle:  TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.grey5E,
      ),
      hintStyle: TextStyle(
        color: AppColors.grey5E,
      ),
      filled: true,
      fillColor: AppColors.greenE1,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 14,
      ),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(),
    );
  }

  static OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: AppRadius.radiusM,
      borderSide: const BorderSide(
        color: AppColors.white,
      ),
    );
  }
}
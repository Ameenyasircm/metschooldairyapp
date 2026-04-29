
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_inputdecoration.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLine;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLine=1,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTypography.body1.copyWith(
        color: AppColors.darkGreen,
      ),
      maxLines:maxLine ,
      decoration: InputDecoration(
        fillColor: AppColors.greyE0,
        filled: true,
        hintText: hintText,
        hintStyle: AppTypography.body1.copyWith(
          color: AppColors.grey5E.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(prefixIcon, size: 20.sp),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusM,
          borderSide: BorderSide(color: AppColors.greyE0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusM,
          borderSide: BorderSide(color:AppColors.greyE0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusM,
          borderSide: const BorderSide(color: Colors.blue, width: 1.2),
        ),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),

      ),
      validator: validator,
    );
  }
}
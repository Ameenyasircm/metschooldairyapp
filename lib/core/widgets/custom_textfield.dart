
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
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greenE1,
        borderRadius: AppRadius.radiusS,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: AppTypography.body1.copyWith(
          color: AppColors.darkGreen,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.body1.copyWith(
            color: AppColors.grey5E.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(prefixIcon, size: 20.sp),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        validator: validator,
      ),
    );
  }
}
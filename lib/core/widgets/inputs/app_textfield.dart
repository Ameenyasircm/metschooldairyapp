
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_inputdecoration.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon; // Fixed type
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLine;
  final Color? fillColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this. prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLine=1,
    this.fillColor=AppColors.greyE0,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.start,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      style: AppTypography.body1.copyWith(
        color: AppColors.darkGreen,
      ),
      maxLines:maxLine ,
      decoration: InputDecoration(
        fillColor:fillColor,
        alignLabelWithHint: true,
        filled: true,
        hintText: hintText,
        labelText: labelText,
        hintStyle: AppTypography.body1.copyWith(
          color: AppColors.grey5E.withValues(alpha: 0.5),
        ),
        prefixIcon: prefixIcon!=null?Icon(prefixIcon, size: 20.sp, color: AppColors.darkGreen):null,
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
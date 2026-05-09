import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      dropdownColor: AppColors.white,
      value: value,
      validator: validator ?? (v) {
        if (v == null) {
          return "Required";
        }
        return null;
      },
      style: AppTypography.body1,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
        labelStyle: AppTypography.body1.copyWith(color: AppColors.grey5E),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusM,
          borderSide: BorderSide(color: AppColors.greyE0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusM,
          borderSide: BorderSide(color: AppColors.greyE0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusM,
          borderSide: const BorderSide(color: Colors.blue, width: 1.2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: AppTypography.body2,),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }
}

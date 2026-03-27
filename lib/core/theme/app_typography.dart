import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  // H1 — 48px SemiBold
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 48.sp,
    color: AppColors.black,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  // H2 — 32px SemiBold (optional but common)
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    height: 1.1,
  );

  // H3 — 22px SemiBold
  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 22.sp,
    color: AppColors.black,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  // H4 — 22px Bold
  static TextStyle h4 = GoogleFonts.inter(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    height: 1.0,
  );

  // H5 — 18px SemiBold
  static TextStyle h5 = GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    height: 1.0,
  );

  // H6 — 16px Medium
  static TextStyle h6 = GoogleFonts.inter(
    fontSize: 16.sp,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  // Subtitle — 16px Medium (125% line height)
  static TextStyle subtitle1 = GoogleFonts.inter(
    fontSize: 16.sp,
    color: AppColors.black,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  // Subtitle 2 — 14px Medium
  static TextStyle subtitle2 = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    height: 1.2,
  );

  // Body 1 — 16px Regular (common)
  static TextStyle body1 = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.2,
  );

  // Body 2 — 14px Regular
  static TextStyle body2 = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    // height: 1.2,
  );

  // Caption — 12px Medium (125%)
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static TextStyle captionL = GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  // Button / Label — 14px Medium
  static TextStyle label = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: AppColors.black,
  );
  static TextStyle interText =GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
}
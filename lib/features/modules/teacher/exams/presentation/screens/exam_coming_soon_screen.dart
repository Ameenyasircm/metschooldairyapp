import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';

class ExamComingSoonScreen extends StatelessWidget {
  const ExamComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Coming soon",
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.h16,
                    Text(
                      "The exams module is under development.\n"
                          "Soon you'll be able to create exams, enter marks,\n"
                          "and view performance reports.",
                      style: AppTypography.body2.copyWith(
                        color: AppColors.grey5E,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.h32,
                    CupertinoActivityIndicator(radius: 16,),
                  ],
                ),
              ),
            ),

            /// 🔷 Bottom Button (sticky style)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusM,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Go Back",style: AppTypography.body2.copyWith(
                    color: Colors.white
                  ),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:shimmer/shimmer.dart';

class StudentShimmer extends StatelessWidget {
  const StudentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin:EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            padding: AppPadding.pS,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusS,
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 22.r),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14.h, color: Colors.white),
                      AppSpacing.h6,
                      Container(height: 12.h, width: 100.w, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
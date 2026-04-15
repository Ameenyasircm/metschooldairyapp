import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/features/home/views/home/home_screen.dart';
import 'package:met_school/features/modules/parent/views/parent_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_padding.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/navigation/navigation_helper.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ParentStudentSelectionScreen extends StatelessWidget {
  final List studentIds;

  const ParentStudentSelectionScreen({
    super.key,
    required this.studentIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: AppColors.primary),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          "Select Student",
          style: AppTypography.h4.copyWith(color: AppColors.primary),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,

        /// 🔴 Logout Button
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.primary),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                callNextReplacement(HomeScreen(), context);
              }
            },
          )
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView.separated(
          itemCount: studentIds.length,
          separatorBuilder: (_, __) => AppSpacing.h16,
          itemBuilder: (context, index) {
            final studentId = studentIds[index];

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("students")
                  .doc(studentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _loadingCard();
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};

                final name = data['name'] ?? "No Name";
                final className = data['className'] ?? "";

                return GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString("selectedStudentId", studentId);

                    if (context.mounted) {
                      callNext(
                        ParentHomeScreen(studentId: studentId),
                        context,
                      );
                    }
                  },
                  child: Container(
                    padding: AppPadding.pL,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.radiusL,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Avatar
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),

                        AppSpacing.w16,

                        /// Student Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              AppSpacing.h4,
                              Text(
                                className,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.grey5E,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(Icons.arrow_forward_ios,
                            size: 16.sp, color: AppColors.grey5E)
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusL,
      ),
    );
  }
}
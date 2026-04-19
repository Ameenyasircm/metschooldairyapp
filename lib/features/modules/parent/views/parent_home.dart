import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_padding.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../providers/conversation_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../conversation/screens/conversation_screen.dart';
import '../../teacher/school_calender/screens/school_calender_mobile_screen.dart';


class ParentHomeScreen extends StatelessWidget {
  final String studentId;
  String academicYearID,teacherName,teacherID;

   ParentHomeScreen({
    super.key,
    required this.studentId,required this.academicYearID,required this.teacherName,required this.teacherID,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Parent Dashboard",
          style: AppTypography.h4.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        /// 🔴 Logout
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.primary),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                callNextReplacement(LoginScreen(), context);
              }
            },
          )
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("students")
            .doc(studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final name = data['name'] ?? "";
          final className = data['className'] ?? "";
          final parentName = data['parentGuardian'] ?? "";
          final classId = data['current_class_id'] ?? "";
          final divisionId = data['current_division_id'] ?? "";

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.h16,

                /// 🎯 Student Card
                Container(
                  width: double.infinity,
                  padding: AppPadding.pL,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.darkGreen,
                      ],
                    ),
                    borderRadius: AppRadius.radiusL,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        className,
                        style: AppTypography.body1.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        "Parent: $parentName",
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.h24,

                /// 🔥 Features Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    children: [
                      _buildCard(Icons.event, "Attendance", onTap: () {}),
                      _buildCard(Icons.payment, "Fees", onTap: () {}),
                      _buildCard(Icons.notifications, "Notices", onTap: () {}),
                      _buildCard(
                        Icons.message_outlined,
                        "Communication",
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          final parentId = prefs.getString("userId") ?? "";

                          final conversationId = await context
                              .read<ConversationProvider>()
                              .getOrCreateConversation(
                            studentId: studentId,
                            parentId: parentId,
                            teacherId: teacherID,
                          );

                          callNext(
                            MessageScreen(
                              conversationId: conversationId,
                              currentUserId: parentId,
                              role: "parent",
                            ),
                            context,
                          );
                        },
                      ),
                      _buildCard(Icons.calendar_month, "School\ncalender", onTap: () {
                        callNext(SchoolCalendarMobileScreen(), context);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
        padding: AppPadding.pM,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.sp, color: AppColors.primary),
            AppSpacing.h12,
            Text(
              title,
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            )
          ],
        ),
      ),
    );
  }
}

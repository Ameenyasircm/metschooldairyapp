import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/conversation_provider.dart';
import '../../conversation/screens/conversation_screen.dart';
import '../../modules/teacher/students/data/models/tech_student_model.dart';
import '../../modules/teacher/students/presentation/provider/student_provider.dart';
import '../models/student_parent_model.dart';

class StudentsParentsListScreen extends StatefulWidget {
  const StudentsParentsListScreen({Key? key}) : super(key: key);

  @override
  State<StudentsParentsListScreen> createState() =>
      _StudentsParentsListScreenState();
}

class _StudentsParentsListScreenState
    extends State<StudentsParentsListScreen> {

  @override
  void initState() {
    super.initState();

    /// ✅ CALL NEW FUNCTION
    Future.microtask(() {
      context.read<StudentProvider>().fetchStudentsWithParentPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();

    /// ✅ NEW LIST
    final List<StudentWithParentModel> students =
        studentProvider.myStudentsWithParent;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              AppSpacing.h24,

              /// 🔹 MAIN CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: AppPadding.pL,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadius.radiusL,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 HEADER
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Punctuality",
                                    style: AppTypography.h4.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "Student Records",
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.grey5E,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.h4,

                      Text(
                        "Student List",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.grey5E,
                        ),
                      ),

                      AppSpacing.h16,

                      /// 🔹 CONTENT
                      Expanded(
                        child: studentProvider
                            .isLoadingMyStudentsWithParent
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : students.isEmpty
                            ? Center(
                          child: Text(
                            "No students found",
                            style: AppTypography.body1.copyWith(
                              color: AppColors.grey5E,
                            ),
                          ),
                        )
                            : ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (_, __) => Divider(
                            color: AppColors.greenE1,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final student = students[index];

                            return InkWell(
                              borderRadius:
                              BorderRadius.circular(16),
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final teacherId = prefs.getString("userId") ?? "";
                                final conversationId = await context
                                    .read<ConversationProvider>()
                                    .getOrCreateConversation(
                                  studentId: student.studentId,
                                  parentId: student.parentId,
                                  teacherId: teacherId,
                                );

                                callNext(
                                  MessageScreen(
                                    conversationId: conversationId,
                                    currentUserId: teacherId,
                                    role: "teacher",
                                  ),
                                  context,
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 6.h),
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius:
                                  BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.greenE1),
                                ),
                                child: Row(
                                  children: [
                                    /// 🔹 Avatar
                                    Container(
                                      height: 45.h,
                                      width: 45.h,
                                      decoration: BoxDecoration(
                                        color:
                                        AppColors.lightGreen,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        student.name.isNotEmpty
                                            ? student.name[0]
                                            .toUpperCase()
                                            : "?",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight:
                                          FontWeight.bold,
                                          color:
                                          AppColors.primary,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 12.w),

                                    /// 🔹 DETAILS
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          /// Student Name
                                          Text(
                                            student.name,
                                            style: AppTypography
                                                .body1
                                                .copyWith(
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),

                                          SizedBox(height: 4.h),

                                          /// Parent Name
                                          Row(
                                            children: [
                                              Icon(Icons.person,
                                                  size: 14.sp,
                                                  color: AppColors
                                                      .grey5E),
                                              SizedBox(width: 4.w),
                                              Expanded(
                                                child: Text(
                                                  student.parentName
                                                      .isNotEmpty
                                                      ? student
                                                      .parentName
                                                      : "No Guardian",
                                                  style:
                                                  AppTypography
                                                      .caption
                                                      .copyWith(
                                                    color: AppColors
                                                        .grey5E,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 2.h),

                                          /// Class
                                          if (student
                                              .className.isNotEmpty)
                                            Text(
                                              student.className,
                                              style:
                                              AppTypography.caption
                                                  .copyWith(
                                                color: AppColors
                                                    .primary
                                                    .withOpacity(0.7),
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    /// 🔹 Arrow
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14.sp,
                                      color: AppColors.grey5E,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.h16,

              /// 🔹 FOOTER
              Text(
                "Select a student to send message",
                style: AppTypography.captionL.copyWith(
                  color: AppColors.grey5E,
                ),
              ),

              AppSpacing.h12,
            ],
          ),
        ),
      ),
    );
  }
}
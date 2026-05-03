import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
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

class _StudentsParentsListScreenState extends State<StudentsParentsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentProvider>().fetchStudentsWithParentPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final List<StudentWithParentModel> students = studentProvider.myStudentsWithParent;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern Light Background
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    // 🔙 Back Button (More Compact)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primary,
                          size: 16.sp,
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    // 📝 Title & Subtitle (Side by Side)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Parent Directory",
                            style: AppTypography.h5.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            "Select a parent to message",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),          Expanded(
            child: studentProvider.isLoadingMyStudentsWithParent
                ? const Center(child: CustomLoader())
                : students.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(context, student);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentWithParentModel student) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () async {
            // Your Original Logic (Retained)
            final prefs = await SharedPreferences.getInstance();
            final teacherId = prefs.getString("staffId") ?? "";
            final senderName = prefs.getString("staffName") ?? "";
            final conversationId = await context
                .read<ConversationProvider>()
                .getOrCreateConversation(
              studentId: student.studentId,
              parentId: student.parentId,
              teacherId: teacherId,
            );

            print('$teacherId EKJFNKJER ');

            callNext(
              MessageScreen(
                conversationId: conversationId,
                currentUserId: teacherId,
                role: "teacher",
                senderName: senderName,
              ),
              context,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                // 🔹 Avatar
                Container(
                  height: 50.h,
                  width: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.1), AppColors.mint.withOpacity(0.2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // 🔹 Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14.sp, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              student.parentName.isNotEmpty ? student.parentName : "No Guardian",
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      if (student.className.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            "Class: ${student.className}",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primary.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 🔹 Chat Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 60.sp, color: Colors.grey.withOpacity(0.3)),
          SizedBox(height: 16.h),
          Text("No students found", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        ],
      ),
    );
  }
}
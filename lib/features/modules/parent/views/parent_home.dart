import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:met_school/features/modules/parent/views/parent_view_homeworks.dart';
import 'package:met_school/features/modules/parent/views/view_parent_instructions.dart';
import 'package:met_school/providers/parent_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_padding.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/conversation_provider.dart';
import '../../../conversation/screens/conversation_screen.dart';
import '../../../mobile_rules_regulations/screens/bellTiming_screen.dart';
import '../../../mobile_rules_regulations/screens/rules_list_screen.dart';
import '../../teacher/school_calender/screens/school_calender_mobile_screen.dart';
import '../attendence/screens/parent_view_attendence_screen.dart';
import '../fee/screens/parent_view_fee.dart';
import '../leaves/presentation/screens/leave_list_screen.dart';
import '../notifications/presentation/provider/notification_provider.dart';
import '../notifications/presentation/screens/parent_notification_screen.dart';
import '../view_time_table/screens/parent_view_time_table.dart';
import 'image_full_screen_view.dart';

class ParentHomeScreen extends StatefulWidget {
  final String studentId;
  final String academicYearID;
  final String teacherName;
  final String teacherID;
  final String parentName;

  const ParentHomeScreen({
    super.key,
    required this.studentId,
    required this.academicYearID,
    required this.teacherName,
    required this.teacherID,
    required this.parentName,
  });

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  String? parentId;
  List<Map<String, dynamic>> students = [];
  String? currentStudentId;
  String? currentAcademicYearId;
  String? currentTeacherId;
  String? currentTeacherName;

  @override
  void initState() {
    super.initState();
    currentStudentId = widget.studentId;
    currentAcademicYearId = widget.academicYearID;
    currentTeacherId = widget.teacherID;
    currentTeacherName = widget.teacherName;

    Future.microtask(() {
      context.read<ParentProvider>().fetchStudent(studentId: currentStudentId??'', academicYearId: currentAcademicYearId??'');
      _initData();
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final studentsJson = prefs.getStringList("studentDataList") ?? [];
    if (mounted) {
      setState(() {
        students = studentsJson
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    parentId = prefs.getString("userId") ?? '';
    if (parentId != null && mounted) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.updateToken(parentId!);
      provider.listenToNotifications(parentId!);
    }
  }

  void _switchStudent(Map<String, dynamic> student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedStudentData", jsonEncode(student));
    await prefs.setString("divisionId", student['divisionId'] ?? "");
    await prefs.setString("divisionName", student['divisionName'] ?? "");
    await prefs.setString("classId", student['classId'] ?? "");
    await prefs.setString("className", student['className'] ?? "");
    await prefs.setString("academicYearId", student['academicYearId'] ?? "");

    setState(() {
      currentStudentId = student['studentId'];
      currentAcademicYearId = student['academicYearId'];
      currentTeacherId = student['teacherId'];
      currentTeacherName = student['teacherName'];
    });

    if (mounted) {
      context.read<ParentProvider>().fetchStudent(academicYearId:widget.academicYearID,studentId: currentStudentId??'');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Consumer<ParentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final name = provider.name;
          final className = provider.className;
          final rollNumber = provider.rollNo;
          final studentPhoto = provider.studentImage;
          // final parentName = provider.parentName;
          final classId = provider.classId;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 10.h),

                /// 🔹 HEADER
                Row(
                  children: [
                    Image.asset(
                      "assets/images/metSchoolPng.png",
                      height: 40.h,
                      errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 40),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("MET PUBLIC SCHOOL",
                              style: AppTypography.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp)),
                          Text("PAYYANAD", style: AppTypography.body2.copyWith(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Action for grid view or notifications
                        callNext(ParentNotificationScreen(parentId: parentId ?? ''), context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.grid_view_rounded, color: Colors.grey.shade700, size: 24.sp),
                      ),
                    )
                  ],
                ),

                AppSpacing.h24,

                /// 🎯 STUDENT CARD (WITH SWITCHER)
                Container(
                  width: double.infinity,
                  padding: AppPadding.pM,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusL,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main Student Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40.r,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: studentPhoto.isNotEmpty?
                              NetworkImage(studentPhoto):
                              AssetImage(AppAssets.profile),
                            ),
                          ),

                          if (students.length > 1)
                            ...students
                                .where((s) => s['studentId'] != currentStudentId)
                                .map((s) => Padding(
                                      padding: EdgeInsets.only(left: 12.w),
                                      child: InkWell(
                                        onTap: () => _switchStudent(s),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: CircleAvatar(
                                            radius: 20.r,
                                            backgroundColor: Colors.grey.shade200,
                                            backgroundImage: (s['studentPhoto']??'').isNotEmpty?
                                                NetworkImage(s['studentPhoto']):AssetImage(AppAssets.profile),
                                          ),
                                        ),
                                      ),
                                    )),
                        ],
                      ),
                      AppSpacing.h12,
                      Text(
                        name,
                        style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacing.h4,
                      Text("$className  •  Roll No:$rollNumber",
                          style: AppTypography.body2.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ),

                AppSpacing.h12,

                /// 🔴 Fee
                const Center(
                  child: Text(
                    "Fee Overdue ₹4,500",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

                AppSpacing.h12,

                /// 🟢 Status
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xffEAF2FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Status", style: AppTypography.body2.copyWith(color: Colors.grey.shade600)),
                      AppSpacing.h4,
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Text(
                            "Present",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSpacing.h20,

                /// Grid Menu
                GridView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.1,
                  ),
                  children: [
                    /// Attendance
                    _menu(Icons.assignment_turned_in_outlined, "Attendance", () async {
                      final prefs = await SharedPreferences.getInstance();
                      final divisionId = prefs.getString("divisionId") ?? '';
                      final divisionName = prefs.getString("divisionName") ?? '';
                      final classId = prefs.getString("classId") ?? '';
                      callNext(
                          ParentViewAttendanceScreen(
                            divisionId: divisionId,
                            divisionName: divisionName,
                            studentId: currentStudentId!,
                            studentName: name,
                            classId: classId,
                          ),
                          context);
                    }),

                    /// Notice
                    _menu(Icons.notifications_active_outlined, "Notice", () {
                      callNext(ParentNotificationScreen(parentId: parentId ?? ''), context);
                    }),

                    /// Calendar
                    _menu(Icons.calendar_month_outlined, "Calendar", () {
                      callNext(SchoolCalendarMobileScreen(), context);
                    }),

                    /// Leaves
                    _menu(Icons.person_remove_outlined, "Leaves", () {
                      callNext(
                        ParentLeaveListScreen(
                          studentId: currentStudentId!,
                          studentName: name,
                          teacherId: currentTeacherId ?? '',
                          academicYearId: currentAcademicYearId ?? '',
                          classId: classId,
                          className: className,
                        ),
                        context,
                      );
                    }),

                    /// Communication
                    _menu(Icons.chat_bubble_outline, "Chat", () async {
                      final prefs = await SharedPreferences.getInstance();
                      final pId = prefs.getString("userId") ?? "";

                      final conversationId = await context.read<ConversationProvider>().getOrCreateConversation(
                            studentId: currentStudentId!,
                            parentId: pId,
                            teacherId: currentTeacherId ?? '',
                          );

                      callNext(
                        MessageScreen(
                          senderName: widget.parentName,
                          conversationId: conversationId,
                          currentUserId: pId,
                          role: "parent",
                        ),
                        context,
                      );
                    }),

                    /// Fees
                    _menu(Icons.payments_outlined, "Fees", () async {
                      final prefs = await SharedPreferences.getInstance();
                      final divisionId = prefs.getString("divisionId") ?? '';
                      final divisionName = prefs.getString("divisionName") ?? '';
                      callNext(
                          ParentFeeScreen(
                            studentName: name,
                            studentId: currentStudentId!,
                            divisionName: divisionName,
                            divisionId: divisionId,
                            academicYearId: currentAcademicYearId ?? '',
                          ),
                          context);
                    }),

                    /// Rules
                    _menu(Icons.gavel_outlined, "Rules & Regulations", () {
                      final provider = context.read<AdminProvider>();
                      provider.fetchRules();
                      callNext(RulesUserScreen(), context);
                    }),

                    /// Instructions
                    _menu(Icons.info_outline, "Instructions", () {
                      callNext(ParentInstructionsScreen(), context);
                    }),

                    /// School Timing
                    _menu(Icons.access_time, "Timing", () {
                      final provider = context.read<AdminProvider>();
                      provider.fetchBellTiming();
                      callNext(BellTimingUserScreen(), context);
                    }),

                    /// Time Table
                    _menu(Icons.table_chart_outlined, "Time Table", () async {
                      final prefs = await SharedPreferences.getInstance();
                      final divisionName = prefs.getString("divisionName") ?? '';
                      final className = prefs.getString("className") ?? '';
                      callNext(
                          StudentTimetableScreen(
                            academicId: currentAcademicYearId ?? '',
                            division: divisionName,
                            standard: className,
                          ),
                          context);
                    }),

                    /// HomeWorks
                    _menu(Icons.workspaces_outline, "HomeWorks", () {
                      callNext(ParentHomeworkScreen(), context);
                    }),
                  ],
                ),

                AppSpacing.h24,
                const Center(
                  child: Text(
                    "School Album",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        callNext(FullScreenImageView(imagePath: "assets/images/sample.jpg", isNetwork: false), context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.asset(
                          "assets/images/sample.jpg",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Icon(Icons.camera_alt, color: Colors.pink),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () {},
                      child: const Icon(Icons.facebook, color: Colors.blue),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () {},
                      child: const Icon(Icons.play_circle, color: Colors.red),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _menu(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26.sp, color: const Color(0xff4A5568)),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xff4A5568),
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

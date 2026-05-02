import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/features/modules/parent/views/view_parent_instructions.dart';
import 'package:met_school/providers/parent_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_padding.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../core/widgets/dialogs/logout_alert.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/conversation_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../conversation/screens/conversation_screen.dart';
import '../../../mobile_rules_regulations/screens/bellTiming_screen.dart';
import '../../../mobile_rules_regulations/screens/rules_list_screen.dart';
import '../../teacher/school_calender/screens/school_calender_mobile_screen.dart';
import '../attendence/screens/parent_view_attendence_screen.dart';
import '../leaves/presentation/screens/leave_list_screen.dart';
import '../notifications/presentation/provider/notification_provider.dart';
import '../notifications/presentation/screens/parent_notification_screen.dart';
import '../notifications/presentation/widgets/notification_badge.dart';
import '../view_time_table/screens/parent_view_time_table.dart';
import 'image_full_screen_view.dart';

class ParentHomeScreen extends StatefulWidget {
  final String studentId;
  String academicYearID, teacherName, teacherID;

   ParentHomeScreen({
    super.key,
    required this.studentId,
    required this.academicYearID,
    required this.teacherName,
    required this.teacherID,
  });

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  String? parentId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ParentProvider>().fetchStudent(widget.studentId);
    });
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    parentId = prefs.getString("userId");
    if (parentId != null && mounted) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.updateToken(parentId!);
      provider.listenToNotifications(parentId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Parent Dashboard",
          style: AppTypography.h4.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (parentId != null)
            NotificationBadge(
              icon: Icons.notifications_none_outlined,
              iconColor: AppColors.primary,
              onTap: () {
                callNext(ParentNotificationScreen(parentId: parentId!), context);
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary),
            onPressed: () => showLogoutDialog(context),
          )
        ],
      ),
      body:Consumer<ParentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final name = provider.name;
          final className = provider.className;
          final parentName = provider.parentName;
          final classId = provider.classId;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                AppSpacing.h16,

                /// 🔹 HEADER (NEW UI)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade200,
                      child: Image.asset(
                        "assets/images/metSchoolPng.png",
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.school),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("MET PUBLIC SCHOOL",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text("PAYYANAD"),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(Icons.grid_view),
                    )
                  ],
                ),

                AppSpacing.h20,

                /// 🎯 STUDENT CARD (UPDATED STYLE)
                Container(
                  width: double.infinity,
                  padding: AppPadding.pL,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: AppRadius.radiusL,
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        // backgroundImage:
                        // AssetImage("assets/images/student.png"),
                      ),
                      AppSpacing.h12,
                      Text(
                        name,
                        style: AppTypography.h4.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                      AppSpacing.h4,
                      Text("$className  •  Roll No: 15"),
                    ],
                  ),
                ),

                AppSpacing.h12,

                /// 🔴 Fee
                const Center(
                  child: Text(
                    "Fee Overdue ₹4,500",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

                AppSpacing.h12,

                /// 🟢 Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffE3E8F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    "● Present",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),

                AppSpacing.h20,

                /// 🔥 IMPORTANT:
                /// USING YOUR ORIGINAL BUTTONS (UNCHANGED)
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  children: [

                    /// Attendance
                    _menu(Icons.event, "Attendance", () async {
                      final prefs = await SharedPreferences.getInstance();
                      final divisionId = prefs.getString("divisionId") ?? '';
                      final divisionName = prefs.getString("divisionName") ?? '';
                      final className = prefs.getString("className") ?? '';
                      callNext(ParentViewAttendanceScreen(
                        divisionId: divisionId,divisionName:divisionName ,
                      studentId: widget.studentId,studentName: name,), context);
                    }),

                    /// Fees
                    _menu(Icons.payment, "Fees", () {}),


                    /// Communication (🔥 ORIGINAL LOGIC)
                    _menu(Icons.message_outlined, "Chat", () async {
                      final prefs = await SharedPreferences.getInstance();

                      final parentId = prefs.getString("userId") ?? "";

                      final conversationId = await context
                          .read<ConversationProvider>()
                          .getOrCreateConversation(
                        studentId: widget.studentId,
                        parentId: parentId,
                        teacherId: widget.teacherID,
                      );

                      callNext(
                        MessageScreen(
                          conversationId: conversationId,
                          currentUserId: parentId,
                          role: "parent",
                        ),
                        context,
                      );
                    }),

                    /// Calendar
                    _menu(Icons.calendar_month, "Calendar", () {
                      callNext(SchoolCalendarMobileScreen(), context);
                    }),

                    /// Leaves
                    _menu(Icons.request_page_outlined, "Leaves", () {
                      callNext(
                        ParentLeaveListScreen(
                          studentId: widget.studentId,
                          studentName: name,
                          teacherId: widget.teacherID,
                          academicYearId: widget.academicYearID,
                          classId: classId,
                          className: className,
                        ),
                        context,
                      );
                    }),

                    /// Parent Instructions
                    _menu(Icons.info, "Instructions", () {
                      callNext(ParentInstructionsScreen(), context);
                    }),

                    /// School Timing
                    _menu(Icons.access_time, "Timing", () {
                      final provider = context.read<AdminProvider>();
                      provider.fetchBellTiming();
                      callNext(BellTimingUserScreen(), context);
                    }),

                    /// Rules
                    _menu(Icons.gavel, "Rules", () {
                      final provider = context.read<AdminProvider>();
                      provider.fetchRules();
                      callNext(RulesUserScreen(), context);
                    }),

                    _menu(Icons.access_time, "Time Table", () async {
                      final prefs = await SharedPreferences.getInstance();
                      final divisionId = prefs.getString("divisionId") ?? '';
                      final divisionName = prefs.getString("divisionName") ?? '';
                      final className = prefs.getString("className") ?? '';
                      callNext(StudentTimetableScreen(academicId: widget.academicYearID,division: divisionName,standard:className ,), context);
                    }),
                  ],
                ),

                AppSpacing.h24,
                const SizedBox(height: 25),

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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6, // you can make dynamic later
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(onTap: (){
                      /// we can pass both network and asset images
                      callNext(FullScreenImageView(imagePath: "assets/images/sample.jpg",isNetwork: false,), context);
                    },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          "assets/images/sample.jpg", // 🔥 CHANGE / MAKE LIST
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

                    /// Instagram
                    InkWell(
                      onTap: () {
                        // open instagram
                      },
                      child: const Icon(Icons.camera_alt, color: Colors.pink),
                    ),

                    const SizedBox(width: 20),

                    /// Facebook
                    InkWell(
                      onTap: () {
                        // open facebook
                      },
                      child: const Icon(Icons.facebook, color: Colors.blue),
                    ),

                    const SizedBox(width: 20),

                    /// YouTube
                    InkWell(
                      onTap: () {
                        // open youtube
                      },
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// ✅ ORIGINAL METHOD (UNCHANGED)
  Widget _buildCard(IconData icon, String title,
      {VoidCallback? onTap}) {
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
            Icon(icon,
                size: 28.sp, color: AppColors.primary),
            AppSpacing.h12,
            Text(
              title,
              textAlign: TextAlign.center,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import '../../../../core/router/app_navigation.dart';
import '../../../../core/widgets/dialogs/logout_alert.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../teacher/profile/presentation/widgets/logout_screen.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  String name = "";
  String phone = "";
  String email = "";
  String role = "";
  String studentName = "";

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("parentName") ??
          prefs.getString("userName") ??
          "Parent";

      phone = prefs.getString("phone") ?? "N/A";
      email = prefs.getString("email") ?? "Not Available";
      role = "Parent";

      /// Optional (if you stored student name)
      studentName = prefs.getString("studentName") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: AppTypography.h5.copyWith(color: AppColors.primary),
        ),
      ),
      body: Padding(
        padding: AppPadding.pL,
        child: Column(
          children: [
            AppSpacing.vs,

            /// 👤 Profile Image
            Image.asset(
              AppAssets.profile,
              width: 80.w,
              height: 80.h,
            ),

            AppSpacing.vm,

            /// 👤 Name
            Text(
              name,
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
              ),
            ),

            /// 👶 Student (Optional)
            if (studentName.isNotEmpty) ...[
              AppSpacing.vs,
              Text(
                "Student: $studentName",
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey9E,
                ),
              ),
            ],

            AppSpacing.vxl,

            /// 📞 Phone
            _buildInfoTile(Icons.phone_outlined, "Phone", phone),

            /// 📧 Email
            _buildInfoTile(Icons.email_outlined, "Email", email),

            /// 🧑 Role
            _buildInfoTile(Icons.person_outline, "Role", role),

            AppSpacing.vs,

            /// 🚪 Logout
            InkWell(
              onTap: () async {
                final shouldLogout = await showLogoutDialog(context);

                if (shouldLogout == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  NavigationService.pushAndRemoveUntil(
                    context,
                    LoginScreen(),
                  );
                }
              },
              child: LogoutTile(),
            ),

            AppSpacing.vxl,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.r),
          ),
          AppSpacing.hm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.grey9E,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
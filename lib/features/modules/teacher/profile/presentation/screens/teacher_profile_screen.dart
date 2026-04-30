import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_assets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/providers/auth_provider.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/constants/app_padding.dart';

import '../../../../../../core/router/app_navigation.dart';
import '../../../../../../core/widgets/dialogs/logout_alert.dart';
import '../../../../../auth/presentation/screens/login_screen.dart';
import '../widgets/logout_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  String name = "";
  String phone = "";
  String email = "";
  String role = "";
  String? profilePic;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("staffName") ?? prefs.getString("userName") ?? "N/A";
      phone = prefs.getString("staffPhone") ?? prefs.getString("phone") ?? "N/A";
      email = prefs.getString("email") ?? "Not Available";
      role = prefs.getString("role") ?? "Teacher";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        title:Text("Profile",style: AppTypography.h5.copyWith(color: AppColors.primary)),
        automaticallyImplyActions: false,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: AppPadding.pL,
        child: Column(
          children: [
            AppSpacing.vs,
            Image.asset(AppAssets.profile, width: 80.w,height: 80.h,),
            AppSpacing.vm,
            Text(
              name,
              style: AppTypography.h3.copyWith(color: AppColors.primary),
            ),

            AppSpacing.vxl,
            _buildInfoTile(Icons.phone_outlined, "Phone", phone),
            _buildInfoTile(Icons.email_outlined, "Email", email),
            AppSpacing.vs,
            InkWell(
                onTap: () async {
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout == true) {
                    final prefs = await SharedPreferences.getInstance();
                    /// Clear saved data
                    await prefs.clear();
                    NavigationService.pushAndRemoveUntil(
                      context,
                      LoginScreen(),
                    );
                  }                },
                child: LogoutTile()),
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
                  style: AppTypography.caption.copyWith(color: AppColors.grey9E),
                ),
                Text(
                  value,
                  style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/admin/views/admin_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../home/views/home/home_screen.dart';
import '../modules/admin/views/admin_home.dart';
import '../modules/parent/views/parent_home.dart';
import '../modules/parent/views/parent_select_child_screen.dart';
import '../modules/teacher/home/presentation/screens/teacher_navbar_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  // Future<void> _startSplash() async {
  //   await Future.delayed(const Duration(seconds: 3));
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     if (!mounted) return;
  //
  //     final authProvider = context.read<AuthProvider>();
  //
  //     /// =========================
  //     /// 🌐 WEB (NO CHANGE)
  //     /// =========================
  //     if (kIsWeb) {
  //       final adminPhone = prefs.getString("adminPhone");
  //       final password = prefs.getString("password");
  //
  //       if (adminPhone == null || adminPhone.isEmpty || password == null) {
  //         callNextReplacement(AdminLoginScreen(), context);
  //         return;
  //       }
  //
  //       await authProvider.loginAdmin(
  //         phoneNumber: adminPhone,
  //         password: password,
  //         context: context,
  //       );
  //     }
  //
  //     /// =========================
  //     /// 📱 MOBILE (UPDATED)
  //     /// =========================
  //     else {
  //       final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  //
  //       if (!isLoggedIn) {
  //         pushAndRemoveUntil(HomeScreen(), context);
  //         return;
  //       }
  //
  //       final role = prefs.getString("role");
  //
  //       /// 🎯 PARENT FLOW
  //       if (role == "parent") {
  //         final studentIds = prefs.getStringList("studentIds") ?? [];
  //
  //         if (studentIds.isEmpty) {
  //           pushAndRemoveUntil(HomeScreen(), context);
  //           return;
  //         }
  //
  //         if (studentIds.length == 1) {
  //           final studentId =
  //               prefs.getString("selectedStudentId") ?? studentIds.first;
  //
  //           callNextReplacement(
  //             ParentHomeScreen(studentId: studentId),
  //             context,
  //           );
  //         } else {
  //           callNextReplacement(
  //             ParentStudentSelectionScreen(studentIds: studentIds),
  //             context,
  //           );
  //         }
  //       }
  //
  //       /// 🎯 TEACHER FLOW
  //       else {
  //         final staffName = prefs.getString("userName") ?? "";
  //
  //         callNextReplacement(
  //           TeacherNavbarScreen(staffName: staffName),
  //           context,
  //         );
  //       }
  //     }
  //   } catch (e, stack) {
  //     debugPrint("Splash error: $e");
  //     debugPrint("$stack");
  //
  //     if (!mounted) return;
  //
  //     /// Fallback navigation
  //     if (kIsWeb) {
  //       callNextReplacement(AdminLoginScreen(), context);
  //     } else {
  //       pushAndRemoveUntil(LoginScreen(), context);
  //     }
  //   }
  // }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();

      /// =========================
      /// 🌐 WEB (NO CHANGE)
      /// =========================
      if (kIsWeb) {
        final adminPhone = prefs.getString("adminPhone");
        final password = prefs.getString("password");

        if (adminPhone == null || adminPhone.isEmpty || password == null) {
          callNextReplacement(AdminLoginScreen(), context);
          return;
        }

        await authProvider.loginAdmin(
          phoneNumber: adminPhone,
          password: password,
          context: context,
        );
      }

      /// =========================
      /// 📱 MOBILE (FINAL)
      /// =========================
      else {
        /// 👉 ALWAYS GO TO HOME
        pushAndRemoveUntil(HomeScreen(), context);
      }
    } catch (e, stack) {
      debugPrint("Splash error: $e");
      debugPrint("$stack");

      if (!mounted) return;

      /// Fallback navigation
      if (kIsWeb) {
        callNextReplacement(AdminLoginScreen(), context);
      } else {
        pushAndRemoveUntil(HomeScreen(), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/LoGoGreenNew.png',
          width: kIsWeb?400:250,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.school,
              size: 100,
              color: Colors.deepPurple,
            );
          },
        ),
      ),
    );
  }
}
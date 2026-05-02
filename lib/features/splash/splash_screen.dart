import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:met_school/core/theme/app_colors.dart';
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
    AuthProvider authPro =
    Provider.of<AuthProvider>(context, listen: false);
    authPro..getAppVersion();
    // authPro.lockApp();
  }


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
      backgroundColor: AppColors.darkBlue2,
      body: SafeArea(
        child: SizedBox(width:MediaQuery.of(context).size.width,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ✅ Main Logo (Perfect Center)
              Image.asset(
                'assets/images/whiteLogoMet.png',
                width: kIsWeb ? 400 : 350,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.school,
                    size: 150,
                    color: Colors.deepPurple,
                  );
                },
              ),

              const Spacer(),

              // ✅ Bottom Logo
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Image.asset(
                  "assets/images/codematesLogo.png",
                  scale: 12,color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
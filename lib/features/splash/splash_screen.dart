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

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    String? adminPhone = prefs.getString("adminPhone");
    String password = prefs.getString("password") ?? "";

    print('$password $adminPhone RJFNRJFNRF ');
    if (!mounted) return;

    /// ❌ No login data → go login
    if (adminPhone == null || adminPhone.isEmpty) {
      callNextReplacement(AdminLoginScreen(), context);
      return;
    }

    /// ✅ Call provider login again
    final authProvider = context.read<AuthProvider>();

    authProvider.loginAdmin(
      phoneNumber: adminPhone,
      password: password,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/metSchoolPng.png',
          width: 250,
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
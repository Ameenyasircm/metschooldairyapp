import 'package:flutter/material.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1000;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Row(
        children: [
          /// ================= LEFT PANEL =================
          if (isDesktop)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    /// Background circle
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    /// Content
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.admin_panel_settings,
                                size: 60, color: Colors.white),
                            SizedBox(height: 30),
                            Text(
                              "Met School\nAdmin Portal",
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Manage operations, track performance,\nand control your system in one place.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// ================= RIGHT PANEL =================
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(30),
                    child: const _LoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscure = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        const Text(
          "Sign In",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Enter your credentials to continue",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 40),

        /// Phone
        const Text("PHONE NUMBER"),
        const SizedBox(height: 6),
        _inputField(
          controller: phoneController,
          hint: "Enter phone number",
          icon: Icons.phone,
        ),

        const SizedBox(height: 20),

        /// Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("PASSWORD"),
            TextButton(
              onPressed: () {},
              child:Text("Forgot Password?",style: AppTypography.caption,),
            )
          ],
        ),

        _inputField(
          controller: passwordController,
          hint: "Enter password",
          icon: Icons.lock,
          obscure: obscure,
          suffix: IconButton(
            icon: Icon(
              obscure ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() => obscure = !obscure);
            },
          ),
        ),

        const SizedBox(height: 30),

        /// Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () {
              context.read<AuthProvider>().loginAdmin(
                phoneNumber: phoneController.text.trim(),
                password: passwordController.text.trim(),
                context: context,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
            ),
            child: authProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Login",style: TextStyle(color: Colors.white),),
          ),
        ),

        const SizedBox(height: 20),

        /// Footer
        const Center(
          child: Text(
            "© 2026 CodeMates",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _login() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate API

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login Clicked")),
    );
  }
}
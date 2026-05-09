import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  // Updated Theme Colors
  static const Color primaryBlue = Color(0xFF031937);
  static const Color secondaryBlue = Color(0xFF003865);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          /// ================= LEFT PANEL (DESKTOP ONLY) =================
          if (isDesktop)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, secondaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative Background Element
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        height: 400,
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // MUCH BIGGER LOGO
                            Image.asset(
                              'assets/images/whiteLogoMet.png',
                              height: size.height * 0.45, // Responsive height (45% of screen)
                              width: 500,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.school, size: 120, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Met School\nAdmin Portal",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 4,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "Secure administrative access to manage operations,\nacademic tracking, and system configurations.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
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

          /// ================= RIGHT PANEL (LOGIN FORM) =================
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFFF8FAFC), // Off-white contrast
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 420,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    const Color primaryBlue = Color(0xFF031937);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show Logo on Mobile View only (where left panel is hidden)
        if (MediaQuery.of(context).size.width <= 1000)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Image.asset(
                'assets/images/whiteLogoMet.png', // Note: You might want a dark version here if the BG is white
                height: 80,
                color: primaryBlue, // Tinting it blue since background is white
              ),
            ),
          ),

        const Text(
          "Sign In",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: primaryBlue,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Authorized personnel only",
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 40),

        /// Phone Number
        _buildLabel("PHONE NUMBER"),
        const SizedBox(height: 8),
        _inputField(
          controller: phoneController,
          hint: "e.g. 9876543210",
          icon: Icons.phone_android_rounded,
        ),

        const SizedBox(height: 25),

        /// Password
        _buildLabel("PASSWORD"),
        const SizedBox(height: 8),
        _inputField(
          controller: passwordController,
          hint: "••••••••",
          icon: Icons.lock_outline_rounded,
          obscure: obscure,
          suffix: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 20,
              color: Colors.blueGrey,
            ),
            onPressed: () => setState(() => obscure = !obscure),
          ),
        ),

        const SizedBox(height: 40),

        /// Login Button
        SizedBox(
          width: double.infinity,
          height: 55,
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
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Text(
              "Access Dashboard",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 30),

        /// Footer
        const Center(
          child: Text(
            "© 2026 CodeMates • All Rights Reserved",
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
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
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF031937), width: 1.5),
        ),
      ),
    );
  }
}
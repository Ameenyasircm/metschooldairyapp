import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators/app_validators.dart';
import '../../../../core/widgets/buttons/gradient_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../providers/auth_provider.dart';
import '../widgets/biometric_button.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
   final formKey =  GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppSpacing.h40,
                  // Logo/Cap Icon
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: AppRadius.radiusM,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.school,
                        color: AppColors.primary,
                        size: 32.sp,
                      ),
                    ),
                  ),
                 AppSpacing.h16,
                  // Title
                  Text(
                    'Academic Atelier',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.h4,
                  // Subtitle
                  Text(
                    'Educator Portal',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.grey5E,
                    ),
                  ),
                  AppSpacing.h32,
                  // Form Card
                  Container(
                    width: double.infinity,
                    padding:AppPadding.pL,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.radiusL,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Welcome back',
                            style: AppTypography.h4.copyWith(
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                        AppSpacing.h24,
                        // EMPLOYEE ID
                        Text(
                          'Phone Number',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.grey5E,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        AppSpacing.h8,
                        AppTextField(
                          controller: phoneController,
                          hintText: 'Enter your phone',
                          keyboardType: TextInputType.phone,
                           inputFormatters: [
                             FilteringTextInputFormatter.digitsOnly,
                             LengthLimitingTextInputFormatter(10)
                           ],
                          prefixIcon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.h20,
                        // PASSWORD
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Password',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.grey5E,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h8,

                        AppTextField(
                          controller: passwordController,
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: authProvider.obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              context.read<AuthProvider>().togglePassword();
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.h24,

                        gradientButton(
                          text: "Login",
                          isLoading:authProvider.isLoading,
                          onPressed:authProvider.isLoading
                              ? null
                              : () {
                            if(formKey.currentState!.validate()){
                              context.read<AuthProvider>().staffLogin(
                                phoneNumber: phoneController.text.trim(),
                                password: passwordController.text.trim(),
                                context: context,
                              );
                            }
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        AppSpacing.h24,
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.greenE1, thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.grey5E,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.greenE1, thickness: 1)),
                          ],
                        ),
                        AppSpacing.h24,
                        // Biometric Row
                        Row(
                          children: [
                            Expanded(
                              child: buildBiometricButton(
                                icon: Icons.fingerprint,
                                text: 'Biometric',
                                onTap: () {},
                              ),
                            ),
                            AppSpacing.w16,
                            Expanded(
                              child: buildBiometricButton(
                                icon: Icons.face_unlock_outlined, // closest standard icon
                                text: 'Face ID',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h40,
                  // Footer
                  Text(
                    'Need assistance with your credentials?',
                    style: AppTypography.captionL.copyWith(
                      color: AppColors.grey5E,
                    ),
                  ),
                  AppSpacing.h4,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Contact the ',
                        style: AppTypography.captionL.copyWith(
                          color: AppColors.grey5E,
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          'IT Support Desk',
                          style: AppTypography.captionL.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h24,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

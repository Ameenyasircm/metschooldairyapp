import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/constants/app_assets.dart';
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
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: formKey,
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.9,
                // color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppSpacing.h20,
                    // Logo/Cap Icon
                    Image.asset(AppAssets.metTextLogo),

                    // AppSpacing.h32,
                    AppSpacing.h40,
                    // EMPLOYEE ID
                    Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: Text(
                        'Phone Number',
                        textAlign: TextAlign.start,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.grey5E,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
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
                      maxLine: 1,
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

                    AppSpacing.h32,

                    Consumer<AuthProvider>(
                      builder: (contextss,val,child) {
                        return gradientButton(
                          text: "Login",
                          isLoading:val.isLoading,
                          onPressed:val.isLoading
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
                        );
                      }
                    ),

                    AppSpacing.h60,
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
      ),
    );
  }
}

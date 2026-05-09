import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/widgets/inputs/app_dropdown.dart';
import 'package:met_school/core/widgets/inputs/app_textfield.dart';

class PersonalInfoStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;
  final TextEditingController aadhaarCtrl;
  final DateTime? dob;
  final String? gender;
  final String? religion;
  final String? cast;
  final File? selectedImage;
  final String? photoUrl;
  final VoidCallback onPickDob;
  final Function(ImageSource) onPickImage;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onReligionChanged;
  final ValueChanged<String?> onCastChanged;

  const PersonalInfoStep({
    super.key,
    required this.nameCtrl,
    required this.ageCtrl,
    required this.aadhaarCtrl,
    required this.dob,
    required this.gender,
    required this.cast,
    required this.religion,
    this.selectedImage,
    this.photoUrl,
    required this.onPickDob,
    required this.onPickImage,
    required this.onGenderChanged,
    required this.onReligionChanged,
    required this.onCastChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImagePicker(context),
        AppSpacing.vl,
        AppTextField(
          controller: nameCtrl,
          hintText: "Full Name",
          labelText: "Full Name",
          prefixIcon: Icons.person_outline,
          fillColor: Colors.white,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter full name";
            }
            return null;
          },
        ),
        AppSpacing.vm,
        FormField<DateTime>(
          initialValue: dob,
          validator: (value) {
            if (dob == null) {
              return "Please select Date of Birth";
            }
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onPickDob,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.radiusM,
                      border: Border.all(
                        color: state.hasError ? Colors.red : AppColors.greyE0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color:
                                state.hasError ? Colors.red : AppColors.darkGreen),
                        AppSpacing.hm,
                        Text(
                          dob == null
                              ? "Select DOB"
                              : DateFormat("dd MMM yyyy").format(dob!),
                          style: AppTypography.body2.copyWith(
                            color: state.hasError ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 5.h, left: 12.w),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 12.sp),
                    ),
                  ),
              ],
            );
          },
        ),
        AppSpacing.vm,
        AppTextField(
          controller: ageCtrl,
          hintText: "Age",
          labelText: "Age",
          prefixIcon: Icons.cake_outlined,
          readOnly: true,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Gender",
          value: gender,
          items: const ["Male", "Female", "Other"],
          onChanged: onGenderChanged,
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Religion",
          value: religion,
          items: const ["Islam", "Hindu", "Christian", "Other"],
          onChanged: onReligionChanged,
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Cast",
          value: cast,
          items: const ["General", "OBC", "SC", "ST"],
          onChanged: onCastChanged,
        ),
        AppSpacing.vm,
        AppTextField(
          controller: aadhaarCtrl,
          hintText: "Aadhaar Number",
          labelText: "Aadhaar Number",
          prefixIcon: Icons.fingerprint,
          keyboardType: TextInputType.number,
          fillColor: Colors.white,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12)
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length != 12) {
              return "Aadhaar must be 12 digits";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              image: selectedImage != null
                  ? DecorationImage(
                      image: FileImage(selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : (photoUrl != null && photoUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: (selectedImage == null && (photoUrl == null || photoUrl!.isEmpty))
                ? Icon(
                    Icons.person,
                    size: 60.sp,
                    color: Colors.grey.shade400,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () => _showPickerOptions(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  onPickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  onPickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

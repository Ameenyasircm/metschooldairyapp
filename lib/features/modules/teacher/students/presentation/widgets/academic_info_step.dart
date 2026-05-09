import 'package:flutter/material.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/widgets/inputs/app_dropdown.dart';
import 'package:met_school/core/widgets/inputs/app_textfield.dart';

class AcademicInfoStep extends StatelessWidget {
  final TextEditingController previousSchoolCtrl;
  final TextEditingController identificationCtrl;

  const AcademicInfoStep({
    super.key,
    required this.previousSchoolCtrl,
    required this.identificationCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSpacing.vm,
        AppTextField(
          controller: previousSchoolCtrl,
          hintText: "Previous School",
          labelText: "Previous School",
          prefixIcon: Icons.school_outlined,
          fillColor: Colors.white,
        ),
        AppSpacing.vm,
        AppTextField(
          controller: identificationCtrl,
          hintText: "Identification Mark",
          labelText: "Identification Mark",
          prefixIcon: Icons.edit_note_outlined,
          fillColor: Colors.white,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/widgets/inputs/app_dropdown.dart';
import 'package:met_school/core/widgets/inputs/app_textfield.dart';

class FamilyInfoStep extends StatelessWidget {
  final TextEditingController parentCtrl;
  final TextEditingController motherCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController whatsappCtrl;
  final String? relation;
  final String? occupation;
  final bool whatsappSame;
  final List<String> occupations;
  final ValueChanged<String?> onRelationChanged;
  final ValueChanged<String?> onOccupationChanged;
  final ValueChanged<bool?> onWhatsappSameChanged;

  const FamilyInfoStep({
    super.key,
    required this.parentCtrl,
    required this.motherCtrl,
    required this.phoneCtrl,
    required this.whatsappCtrl,
    required this.relation,
    required this.occupation,
    required this.whatsappSame,
    required this.occupations,
    required this.onRelationChanged,
    required this.onOccupationChanged,
    required this.onWhatsappSameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: parentCtrl,
          hintText: "Parent/Guardian",
          labelText: "Parent/Guardian",
          prefixIcon: Icons.person,
          fillColor: Colors.white,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter Parent/Guardian";
            }
            return null;
          },
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Relation",
          value: relation,
          items: const ["Father", "Mother", "Brother", "Sister", "Other"],
          onChanged: onRelationChanged,
        ),
        AppSpacing.vm,
        AppDropdown(
          label: "Occupation",
          value: occupation,
          items: occupations,
          onChanged: onOccupationChanged,
        ),
        AppSpacing.vm,
        AppTextField(
          controller: motherCtrl,
          hintText: "Mother Name",
          labelText: "Mother Name",
          prefixIcon: Icons.woman,
          fillColor: Colors.white,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter Mother Name";
            }
            return null;
          },
        ),
        AppSpacing.vm,
        AppTextField(
          controller: phoneCtrl,
          hintText: "Phone Number",
          labelText: "Phone Number",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
           LengthLimitingTextInputFormatter(10)
          ],
          fillColor: Colors.white,
          onChanged: (v) {
            if (whatsappSame) {
              whatsappCtrl.text = v;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter Phone Number";
            }
            return null;
          },

        ),
        AppSpacing.vs,
        Row(
          children: [
            Checkbox(
              value: whatsappSame,
              activeColor: AppColors.primary,
              onChanged: onWhatsappSameChanged,
            ),
            Expanded(
              child: Text(
                "WhatsApp same as phone number",
                style: AppTypography.body2,
              ),
            ),
          ],
        ),
        AppSpacing.vs,
        AppTextField(
          controller: whatsappCtrl,
          hintText: "WhatsApp Number",
          labelText: "WhatsApp Number",
          prefixIcon: Icons.chat,
          keyboardType: TextInputType.phone,
          readOnly: whatsappSame,
          fillColor: Colors.white,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10)
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter WhatsApp Number";
            }
            return null;
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:met_school/core/constants/app_constants.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/widgets/inputs/app_dropdown.dart';
import 'package:met_school/core/widgets/inputs/app_textfield.dart';

class AddressInfoStep extends StatelessWidget {
  final TextEditingController placeCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController previousSchoolCtrl;
  final TextEditingController identificationCtrl;
  final String? feeType;
  final ValueChanged<String?> onFeeTypeChanged;

  const AddressInfoStep({
    super.key,
    required this.placeCtrl,
    required this.addressCtrl,
    required this.previousSchoolCtrl,
    required this.identificationCtrl,
    required this.feeType,
    required this.onFeeTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppDropdown(
          label: "Fee Type",
          value: feeType,
          items: AppConstants.feeTypes.keys.toList(),
          onChanged: onFeeTypeChanged,
        ),
        AppSpacing.vm,
        AppTextField(
          controller: placeCtrl,
          hintText: "Place",
          labelText: "Place",
          prefixIcon: Icons.location_on_outlined,
          fillColor: Colors.white,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter Place";
            }
            return null;
          },

        ),
        AppSpacing.vm,
        AppTextField(
          controller: addressCtrl,
          hintText: "Address",
          labelText: "Address",
          prefixIcon: Icons.home_outlined,
          maxLine: 4,
          fillColor: Colors.white,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter Address";
            }
            return null;
          },
        ),
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

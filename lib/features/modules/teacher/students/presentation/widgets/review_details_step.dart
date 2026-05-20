import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/enrollment_review_tile.dart';

class ReviewDetailsStep extends StatelessWidget {
  final String name;
  final String dob;
  final String age;
  final String gender;
  final String religion;
  final String cast;
  final String parent;
  final String phone;
  final String place;
  final String address;
  final String feeType;
  final File? selectedImage;
  final String? photoUrl;

  const ReviewDetailsStep({
    super.key,
    required this.name,
    required this.dob,
    required this.age,
    required this.gender,
    required this.religion,
    required this.cast,
    required this.parent,
    required this.phone,
    required this.place,
    required this.address,
    required this.feeType,
    this.selectedImage,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedImage != null || (photoUrl != null && photoUrl!.isNotEmpty))
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: CircleAvatar(
              radius: 50.r,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : NetworkImage(photoUrl!) as ImageProvider,
            ),
          ),
        EnrollmentReviewTile(title: "Name", value: name),
        EnrollmentReviewTile(title: "Dob", value: dob),
        EnrollmentReviewTile(title: "Age", value: age),
        EnrollmentReviewTile(title: "Gender", value: gender),
        EnrollmentReviewTile(title: "Religion", value: religion),
        EnrollmentReviewTile(title: "Cast", value: cast),
        EnrollmentReviewTile(title: "Parent", value: parent),
        EnrollmentReviewTile(title: "Phone", value: phone),
        EnrollmentReviewTile(title: "Place", value: place),
        EnrollmentReviewTile(title: "Address", value: address),
        EnrollmentReviewTile(title: "Fee Type", value: feeType),
      ],
    );
  }
}

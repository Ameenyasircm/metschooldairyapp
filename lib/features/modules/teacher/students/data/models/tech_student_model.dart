class TechStudentModel {
  final String studentId;
  final String name;
  final String parentPhone;
  final String dob;
  final String bloodGroup;
  final String address;
  final String admissionNumber;

  TechStudentModel({
    required this.studentId,
    required this.name,
    required this.parentPhone,
    required this.dob,
    required this.bloodGroup,
    required this.address,
    required this.admissionNumber,
  });

  factory TechStudentModel.fromMap(Map<String, dynamic> map) {
    return TechStudentModel(
      studentId: map['student_id'] ?? '',
      name: map['name'] ?? '',
      parentPhone: map['parent_phone'] ?? '',
      dob: map['dob'] ?? '',
      bloodGroup: map['blood_group'] ?? '',
      address: map['address'] ?? '',
      admissionNumber: map['admission_number'] ?? '',
    );
  }
}
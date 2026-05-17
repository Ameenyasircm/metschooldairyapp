/// add_lesson_plan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/features/modules/teacher/syllabus/presentation/provider/syllabus_provider.dart';
import 'package:met_school/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/loader/customLoader.dart';

class AddLessonPlanScreen extends StatefulWidget {
  const AddLessonPlanScreen({super.key});

  @override
  State<AddLessonPlanScreen> createState() => _AddLessonPlanScreenState();
}

class _AddLessonPlanScreenState extends State<AddLessonPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SyllabusProvider>().fetchSubjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Lesson Plan",
          style: AppTypography.body1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Consumer2<TeacherProvider, SyllabusProvider>(
          builder: (context, teacherProvider, subjectProvider, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Subject Dropdown ──────────────────
                    DropdownButtonFormField<String>(
                      value: teacherProvider.selectedSubjectId,
                      decoration: _decoration("Select Subject"),
                      items: subjectProvider.subjectsList.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject['id'],
                          child: Text(subject['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        final selected = subjectProvider.subjectsList
                            .firstWhere((e) => e['id'] == value);
                        teacherProvider.setSelectedSubject(
                          id: value,
                          name: selected['name'],
                        );
                      },
                      validator: (value) =>
                      value == null ? "Please select subject" : null,
                    ),

                    AppSpacing.h14,

                    // ── Single-line fields ────────────────
                    _field(teacherProvider.gradeController,
                        "Grade"),
                    _field(teacherProvider.topicController,
                        "Topic / Chapter Name"),
                    _field(teacherProvider.durationController,
                        "Duration (e.g. June 5 – 9)"),
                    _field(teacherProvider.periodsController,
                        "Number Of Periods"),

                    // ── Expandable / multi-line fields ────
                    _field(
                      teacherProvider.methodologiesController,
                      "Methodologies",
                      minLines: 3,
                    ),
                    _field(
                      teacherProvider.activityController,
                      "Activity",
                      minLines: 3,
                    ),
                    _field(
                      teacherProvider.instructionalController,
                      "Instructional Tools",
                      minLines: 2,
                    ),
                    _field(
                      teacherProvider.objectivesController,
                      "Learning Objectives",
                      minLines: 3,
                    ),

                    AppSpacing.h24,

                    // ── Submit ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: teacherProvider.isLoading
                            ? null
                            : () async {
                          if (!_formKey.currentState!.validate()) return;

                          await teacherProvider.submitLessonPlan(
                            context: context,
                            teacherId: "TEACHER_001",
                            teacherName: "Teacher Name",
                          );

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: teacherProvider.isLoading
                            ? const CustomLoader()
                            : Text(
                          "Submit Lesson Plan",
                          style: AppTypography.body2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.h30,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Field — expands as user types ─────────────────────────
  Widget _field(
      TextEditingController controller,
      String hint, {
        int minLines = 1, // starting height
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: controller,
        minLines: minLines,   // starts at minLines rows tall
        maxLines: null,       // ← no cap; grows with content
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: _decoration(hint),
        validator: (value) =>
        (value == null || value.trim().isEmpty) ? "Required" : null,
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}
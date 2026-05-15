import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_padding.dart';
import 'package:met_school/core/theme/app_radius.dart';
import 'package:met_school/core/theme/app_spacing.dart';
import 'package:met_school/core/theme/app_typography.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/teacher/home/data/models/subject_assignment_model.dart';
import 'package:met_school/providers/teacher_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/router/app_navigation.dart';
import 'subject_action_screen.dart';

class SubjectClassDivisionSelector extends StatelessWidget {
  const SubjectClassDivisionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        final assignments = provider.subjectAssignments;
        
        // Group assignments by Class and Division
        final Map<String, List<SubjectAssignmentModel>> grouped = {};
        for (var assignment in assignments) {
          final key = "${assignment.className} - ${assignment.divisionName}";
          if (!grouped.containsKey(key)) {
            grouped[key] = [];
          }
          grouped[key]!.add(assignment);
        }

        final groupKeys = grouped.keys.toList();

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final key = groupKeys[index];
                final groupAssignments = grouped[key]!;
                final first = groupAssignments.first;

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusL,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: AppPadding.pS,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.radiusM,
                        ),
                        child: Icon(Icons.class_outlined, color: AppColors.primary, size: 24.sp),
                      ),
                      title: Text(
                        first.className,
                        style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Division: ${first.divisionName}",
                        style: AppTypography.caption.copyWith(color: AppColors.grey5E),
                      ),
                      children: [
                        const Divider(height: 1),
                        ...groupAssignments.map((assignment) => ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                          title: Text(
                            assignment.subjectName,
                            style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: AppColors.grey5E),
                          onTap: () {
                            NavigationService.push(
                              context,
                              SubjectActionScreen(assignment: assignment),
                            );
                          },
                        )),
                      ],
                    ),
                  ),
                );
              },
              childCount: groupKeys.length,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/features/modules/teacher/home/presentation/widgets/quick_action_card.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/teacher_home_viewmodel.dart';

Widget buildQuickActions(BuildContext context) {
  return Consumer<TeacherHomeViewModel>(
    builder: (context, vm, _) {
      final actions = vm.quickActions;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.4,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return QuickActionCard(action: actions[index]);
        },
      );
    },
  );
}
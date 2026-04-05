import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_typography.dart';

Widget buildEmptyState() {
  return ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: 200.h),
      Center(
        child: Text("No students found", style: AppTypography.body1),
      ),
    ],
  );
}
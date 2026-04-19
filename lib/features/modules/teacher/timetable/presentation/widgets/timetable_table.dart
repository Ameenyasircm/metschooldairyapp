import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../provider/timetable_provider.dart';

class TimetableTable extends StatelessWidget {
  const TimetableTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            // CRITICAL: Horizontal ScrollView to prevent overflow with 8 columns
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Table(
                defaultColumnWidth: FixedColumnWidth(100.w),
                border: TableBorder.all(color: AppColors.greyB2, width: 0.5),
                children: [
                  // Header Row
                  TableRow(
                    decoration: const BoxDecoration(color: AppColors.primary),
                    children: [
                      _buildHeaderCell('Day'),
                      for (int i = 1; i <= 7; i++) _buildHeaderCell('P$i'),
                    ],
                  ),
                  // Data Rows
                  ...provider.days.map((day) => _buildDayRow(context, day, provider)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
      child: Center(
        child: Text(
          text,
          style: AppTypography.subtitle2.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  TableRow _buildDayRow(BuildContext context, String day, TimetableProvider provider) {
    return TableRow(
      children: [
        // Day Column
        Container(
          color: AppColors.greenE1.withOpacity(0.3),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
          child: Center(
            child: Text(day, style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        // Periods Columns
        ...List.generate(7, (index) {
          if (provider.isEditing) {
            return Padding(
              padding: EdgeInsets.all(4.w),
              child: TextField(
                controller: provider.controllers[day]![index],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
                style: AppTypography.body2,
              ),
            );
          } else {
            final period = provider.timetable?.timetable[day]?[index] ?? '';
            return Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text(period, style: AppTypography.body2, textAlign: TextAlign.center),
            );
          }
        }),
      ],
    );
  }
}

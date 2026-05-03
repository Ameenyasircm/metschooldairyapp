import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_padding.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/loader/customLoader.dart';
import '../../../homework/providers/homework_provider.dart';

class ParentHomeworkScreen extends StatefulWidget {
  const ParentHomeworkScreen({super.key});

  @override
  State<ParentHomeworkScreen> createState() =>
      _ParentHomeworkScreenState();
}

class _ParentHomeworkScreenState extends State<ParentHomeworkScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HomeworkProvider>().fetchHomework();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Text(
          "Homework",
          style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () =>
                context.read<HomeworkProvider>().fetchHomework(),
          )
        ],
      ),
      body: Consumer<HomeworkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.homeworkList.isEmpty) {
            return const Center(child: CustomLoader());
          }

          if (provider.homeworkList.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: AppPadding.pM,
            itemCount: provider.homeworkList.length,
            itemBuilder: (context, index) {
              final hw = provider.homeworkList[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// SUBJECT + DATE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hw.subject!,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM').format(hw.dueDate),
                          style: AppTypography.caption.copyWith(
                            color: _isExpired(hw.dueDate)
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// TITLE
                    Text(
                      hw.title,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// DESCRIPTION
                    if (hw.description.isNotEmpty)
                      Text(
                        hw.description,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.grey5E,
                        ),
                      ),

                    const SizedBox(height: 10),

                    /// FOOTER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "By ${hw.teacherName}",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.grey5E,
                          ),
                        ),
                        _statusChip(hw.dueDate),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(DateTime dueDate) {
    final expired = _isExpired(dueDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: expired
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        expired ? "Expired" : "Active",
        style: TextStyle(
          color: expired ? Colors.red : Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _isExpired(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 70, color: AppColors.grey5E.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            "No homework available",
            style: AppTypography.body2.copyWith(
              color: AppColors.grey5E,
            ),
          ),
        ],
      ),
    );
  }
}
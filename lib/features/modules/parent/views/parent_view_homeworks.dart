import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_padding.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/loader/customLoader.dart';
import '../../../homework/providers/homework_provider.dart';

class ParentHomeworkScreen extends StatefulWidget {
   ParentHomeworkScreen({super.key});

  @override
  State<ParentHomeworkScreen> createState() => _ParentHomeworkScreenState();
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
            onPressed: () => context.read<HomeworkProvider>().fetchHomework(),
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

              // ← Pull submission status from provider
              final submissionStatus =
                  provider.submissionStatuses[hw.id] ?? 'not_submitted';
              final submissionDate = provider.submissionDates[hw.id];    // ← add here
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
                    /// SUBJECT + DUE DATE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hw.subject ?? '',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Due: ${DateFormat('dd MMM').format(hw.dueDate)}",
                          style: AppTypography.caption.copyWith(
                            color: _isExpired(hw.dueDate)
                                ? Colors.red
                                : Colors.grey,
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

                    /// FOOTER — teacher name + submission status chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "By ${hw.teacherName}",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.grey5E,
                          ),
                        ),
                        _submissionChip(submissionStatus, submissionDate),// ← updated
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

  /// Shows Completed / Pending / Not Submitted based on Firestore data
  Widget _submissionChip(String status, DateTime? completedOn) {
    late Color bgColor;
    late Color textColor;
    late IconData icon;
    late String label;

    switch (status) {
      case 'completed':
        bgColor = const Color(0xFFE8F8EE);
        textColor = const Color(0xFF1B8E4B);
        icon = Icons.check_circle_rounded;

        label = completedOn != null
            ? 'Completed'
            : 'Completed';
        break;

      case 'pending':
        bgColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFE38B00);
        icon = Icons.access_time_rounded;
        label = 'Pending';
        break;

      default:
        bgColor = const Color(0xFFFFEAEA);
        textColor = const Color(0xFFD92D20);
        icon = Icons.cancel_rounded;
        label = 'Not Submitted';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: textColor.withOpacity(.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: textColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (completedOn != null && status == 'completed') ...[
            const SizedBox(height: 3),
            Text(
              DateFormat('dd MMM yyyy hh:mm aa').format(completedOn),
              style: TextStyle(
                color: textColor.withOpacity(.75),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isExpired(DateTime date) => date.isBefore(DateTime.now());

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
            style: AppTypography.body2.copyWith(color: AppColors.grey5E),
          ),
        ],
      ),
    );
  }
}
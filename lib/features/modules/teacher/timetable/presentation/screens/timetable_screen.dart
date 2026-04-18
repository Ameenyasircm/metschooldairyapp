import 'package:flutter/material.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../provider/timetable_provider.dart';
import '../widgets/timetable_table.dart';

class TimetableScreen extends StatefulWidget {
  final String academicId;
  final String standard;
  final String division;

  const TimetableScreen({
    super.key,
    required this.academicId,
    required this.standard,
    required this.division,
  });

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableProvider>().fetchTimetable(widget.standard,widget.division,widget.academicId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Class ${widget.standard}-${widget.division} Timetable',
            style: AppTypography.h6.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          Consumer<TimetableProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.timetable == null) {
                return const SizedBox.shrink();
              }
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: provider.isSaving 
                      ? null 
                      : () async {
                          if (provider.isEditing) {
                            final success = await provider.saveTimetable();
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all 35 periods before saving.'),
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Timetable saved successfully!'),
                                  backgroundColor: AppColors.successGreen,
                                ),
                              );
                            }
                          } else {
                            provider.toggleEditMode();
                          }
                        },
                  icon: provider.isSaving 
                      ? const SizedBox(
                          width: 18, 
                          height: 18, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          provider.isEditing ? Icons.check_circle_outline : Icons.edit_note,
                          color: AppColors.white,
                        ),
                  label: Text(
                    provider.isSaving 
                        ? 'Saving...' 
                        : (provider.isEditing ? 'Save' : 'Edit'),
                    style: AppTypography.label.copyWith(color: AppColors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimetableProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.timetable == null) {
            return const Center(child: CustomLoader());
          }
          return const TimetableTable();
        },
      ),
    );
  }
}

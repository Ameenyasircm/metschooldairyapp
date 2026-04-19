import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/router/app_navigation.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../provider/homework_provider.dart';
import 'add_homework_screen.dart';
import 'homework_student_status_screen.dart';

class HomeworkListScreen extends StatefulWidget {
  const HomeworkListScreen({super.key});

  @override
  State<HomeworkListScreen> createState() => _HomeworkListScreenState();
}

class _HomeworkListScreenState extends State<HomeworkListScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final classId = prefs.getString("classId") ?? '';
    final divisionId = prefs.getString("divisionId") ?? '';
    
    if (mounted) {
      context.read<HomeworkProvider>().fetchHomework(
        classId: classId,
        divisionId: divisionId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Homework Management',
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<HomeworkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.homeworkList.isEmpty) {
            return const Center(child: CustomLoader());
          }

          if (provider.homeworkList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No homework assigned yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppPadding.pM,
            itemCount: provider.homeworkList.length,
            itemBuilder: (context, index) {
              final homework = provider.homeworkList[index];
              final isOverdue = homework.dueDate.isBefore(DateTime.now()) && 
                                !DateUtils.isSameDay(homework.dueDate, DateTime.now());

              return Card(
                color: AppColors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          homework.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      if (homework.subject != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            homework.subject!,
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.h4,
                      Text(
                        homework.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      AppSpacing.h8,
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: isOverdue ? Colors.red : Colors.grey),
                          AppSpacing.w4,
                          Text(
                            'Due: ${DateFormat('dd MMM').format(homework.dueDate)}',
                            style: TextStyle(
                              fontSize: 12, 
                              color: isOverdue ? Colors.red : Colors.grey[700],
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Posted: ${DateFormat('dd MMM').format(homework.createdAt)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeworkStudentStatusScreen(homework: homework),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
         NavigationService.push(context, AddHomeworkScreen());
        },
        label:Text('Add Homework',style: AppTypography.caption
            .copyWith(color: Colors.white, fontWeight: FontWeight.w600),),
        icon: const Icon(Icons.add,color: Colors.white),
      ),
    );
  }
}

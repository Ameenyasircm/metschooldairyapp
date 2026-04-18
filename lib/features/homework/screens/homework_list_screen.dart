import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_padding.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/loader/customLoader.dart';
import '../providers/homework_provider.dart';
import '../widgets/homework_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeworkProvider>().fetchHomework();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Homework Management',
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => context.read<HomeworkProvider>().fetchHomework(),
          ),
        ],
      ),
      body: Consumer<HomeworkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.homeworkList.isEmpty) {
            return const Center(child: CustomLoader());
          }

          if (provider.homeworkList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: AppPadding.pM,
            itemCount: provider.homeworkList.length,
            itemBuilder: (context, index) {
              final homework = provider.homeworkList[index];
              return HomeworkCard(
                homework: homework,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomeworkStudentStatusScreen(homework: homework),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddHomeworkScreen()),
        ),
        backgroundColor: AppColors.primary,
        label: Text('Add Homework',
            style: AppTypography.body2.copyWith(color: AppColors.white)),
        icon: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: AppColors.grey5E.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No homework assigned yet',
              style: AppTypography.body2.copyWith(color: AppColors.grey5E)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../data/models/homework_model.dart';
import '../provider/homework_provider.dart';
import '../widgets/homework_student_list.dart';

class HomeworkStudentStatusScreen extends StatefulWidget {
  final HomeworkModel homework;
  const HomeworkStudentStatusScreen({super.key, required this.homework});

  @override
  State<HomeworkStudentStatusScreen> createState() => _HomeworkStudentStatusScreenState();
}

class _HomeworkStudentStatusScreenState extends State<HomeworkStudentStatusScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSubmissions();
    });
  }

  void _fetchSubmissions() {
    context.read<HomeworkProvider>().fetchSubmissions(widget.homework.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(widget.homework.title, style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<HomeworkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CustomLoader());
          }

          final pending = provider.submissions.where((s) => s.status == 'pending').toList();
          final completed = provider.submissions.where((s) => s.status == 'completed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              HomeworkStudentList(
                students: pending,
                isPending: true,
                homeworkId: widget.homework.id,
                homeworkTitle: widget.homework.title,
              ),
              HomeworkStudentList(
                students: completed,
                isPending: false,
                homeworkId: widget.homework.id,
                homeworkTitle: widget.homework.title,
              ),
            ],
          );
        },
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/loader/customLoader.dart';
import '../../../../core/constants/app_padding.dart';
import '../models/homework_model.dart';
import '../providers/homework_provider.dart';

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
      context.read<HomeworkProvider>().fetchSubmissions(widget.homework.id);
    });
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
        title: Text(widget.homework.title,
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey5E,
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
              _StudentStatusList(
                students: pending,
                isPending: true,
                homeworkId: widget.homework.id,
                homeworkTitle: widget.homework.title,
              ),
              _StudentStatusList(
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

class _StudentStatusList extends StatelessWidget {
  final List<HomeworkSubmissionModel> students;
  final bool isPending;
  final String homeworkId;
  final String homeworkTitle;

  const _StudentStatusList({
    required this.students,
    required this.isPending,
    required this.homeworkId,
    required this.homeworkTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'All students have completed!' : 'No completions yet.',
          style: AppTypography.body2.copyWith(color: AppColors.grey5E),
        ),
      );
    }

    return ListView.builder(
      padding: AppPadding.pM,
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          color: AppColors.lightBackground,
          child: ListTile(
            onTap: () => _showStatusToggleDialog(context, student),
            leading: CircleAvatar(
              backgroundColor: isPending ? Colors.red.shade50 : Colors.green.shade50,
              child: Text(
                student.studentName[0].toUpperCase(),
                style: AppTypography.body1.copyWith(
                  color: isPending ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(student.studentName,
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text(
              isPending ? 'Pending' : 'Completed',
              style: AppTypography.caption.copyWith(
                color: isPending ? Colors.red : Colors.green,
              ),
            ),
            trailing: isPending && student.parentPhone != null && student.parentPhone!.isNotEmpty
                ? _CommunicationActions(
                    phone: student.parentPhone!,
                    studentName: student.studentName,
                    homeworkTitle: homeworkTitle,
                  )
                : !isPending
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                    : null,
          ),
        );
      },
    );
  }

  void _showStatusToggleDialog(BuildContext context, HomeworkSubmissionModel student) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update Status', style: AppTypography.h6),
        content: Text(
          'Mark ${student.studentName}\'s homework as ${isPending ? 'Completed' : 'Pending'}?',
          style: AppTypography.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey5E)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<HomeworkProvider>().updateSubmissionStatus(
                    homeworkId: homeworkId,
                    studentId: student.studentId,
                    status: isPending ? 'completed' : 'pending',
                  );
            },
            child: Text('Update', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _CommunicationActions extends StatelessWidget {
  final String phone;
  final String studentName;
  final String homeworkTitle;

  const _CommunicationActions({
    required this.phone,
    required this.studentName,
    required this.homeworkTitle,
  });

  Future<void> _makeCall() async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendWhatsApp() async {
    final message = "Dear Parent, this is a reminder regarding the homework '$homeworkTitle' for $studentName. It is currently pending. Please ensure it is completed by the due date.";
    final Uri uri = Uri.parse("whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}");
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        final Uri smsUri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': message});
        if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
      }
    } catch (e) {
      debugPrint("Could not launch WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.blue, size: 20),
          onPressed: _makeCall,
        ),
        IconButton(
          icon: const Icon(Icons.message, color: Colors.green, size: 20),
          onPressed: _sendWhatsApp,
        ),
      ],
    );
  }
}

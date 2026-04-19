import 'package:flutter/material.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../data/models/homework_model.dart';
import '../provider/homework_provider.dart';

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

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber, String studentName) async {
    final message = "Dear Parent, this is a reminder regarding the homework '${widget.homework.title}' for $studentName. It is currently pending. Please ensure it is completed by the due date.";
    final Uri whatsappUri = Uri.parse("whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}");
    
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        // Fallback to SMS
        final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: {'body': message});
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      }
    } catch (e) {
      debugPrint("Could not launch WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(widget.homework.title,style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
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
              _buildStudentList(pending, isPending: true),
              _buildStudentList(completed, isPending: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentList(List<HomeworkSubmissionModel> students, {required bool isPending}) {
    if (students.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'All students have completed!' : 'No completions yet.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          onTap: () => _showStatusToggleDialog(student),
          leading: CircleAvatar(
            backgroundColor: isPending ? Colors.red.shade100 : Colors.green.shade100,
            child: Text(
              student.studentName[0].toUpperCase(),
              style: TextStyle(color: isPending ? Colors.red : Colors.green),
            ),
          ),
          title: Text(student.studentName, style: AppTypography.body1.copyWith(fontWeight: FontWeight.w500)),
          subtitle: Text(isPending ? 'Pending' : 'Completed', style: TextStyle(color: isPending ? Colors.red : Colors.green, fontSize: 12)),
          trailing: isPending && student.parentPhone != null && student.parentPhone!.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.blue),
                      onPressed: () => _makeCall(student.parentPhone!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.green),
                      onPressed: () => _sendWhatsApp(student.parentPhone!, student.studentName),
                    ),
                  ],
                )
              : isPending ? null : const Icon(Icons.check_circle, color: Colors.green),
        );
      },
    );
  }

  void _showStatusToggleDialog(HomeworkSubmissionModel student) {
    final bool isCurrentlyPending = student.status == 'pending';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Update Status'),
        content: Text('Mark ${student.studentName}\'s homework as ${isCurrentlyPending ? 'Completed' : 'Pending'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<HomeworkProvider>().updateSubmissionStatus(
                homeworkId: widget.homework.id,
                studentId: student.studentId,
                status: isCurrentlyPending ? 'completed' : 'pending',
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging && _isSelectionMode) {
        setState(() {
          _isSelectionMode = false;
          _selectedIds.clear();
        });
      }
    });
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

  void _toggleSelection(String studentId) {
    setState(() {
      if (_selectedIds.contains(studentId)) {
        _selectedIds.remove(studentId);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(studentId);
        _isSelectionMode = true;
      }
    });
  }

  void _showBulkUpdateDialog(BuildContext context) {
    final isPendingTab = _tabController.index == 0;
    final newStatus = isPendingTab ? 'completed' : 'pending';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Update Status', style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
          'Mark ${_selectedIds.length} students as ${isPendingTab ? 'Completed' : 'Pending'}?',
          style: AppTypography.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTypography.subtitle2.copyWith(color: AppColors.grey5E)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final idsToUpdate = _selectedIds.toList();
              setState(() {
                _isSelectionMode = false;
                _selectedIds.clear();
              });
              await context.read<HomeworkProvider>().bulkUpdateSubmissionStatus(
                    homeworkId: widget.homework.id,
                    studentIds: idsToUpdate,
                    status: newStatus,
                  );
            },
            child: Text('Update', style: AppTypography.subtitle2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                }),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: _isSelectionMode
            ? Text('${_selectedIds.length} Selected',
                style: AppTypography.h6.copyWith(fontWeight: FontWeight.w600, color: Colors.black))
            : Text(widget.homework.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600, color: Colors.black)),
        actions: [
          if (!_isSelectionMode)
            IconButton(
              onPressed: () => setState(() => _isSelectionMode = true),
              icon: const Icon(Icons.checklist, color: AppColors.primary, size: 28),
              tooltip: 'Select Multiple',
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.black),
              onPressed: () {
                final provider = context.read<HomeworkProvider>();
                final currentTabStudents = _tabController.index == 0
                    ? provider.submissions.where((s) => s.status == 'pending').toList()
                    : provider.submissions.where((s) => s.status == 'completed').toList();
                setState(() {
                  if (_selectedIds.length == currentTabStudents.length) {
                    _selectedIds.clear();
                  } else {
                    _selectedIds.addAll(currentTabStudents.map((s) => s.studentId));
                  }
                });
              },
            ),
        ],
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
          if (provider.isLoading && provider.submissions.isEmpty) {
            return const Center(child: CustomLoader());
          }

          final pending = provider.submissions.where((s) => s.status == 'pending').toList();
          final completed = provider.submissions.where((s) => s.status == 'completed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildStudentList(pending, true),
              _buildStudentList(completed, false),
            ],
          );
        },
      ),
      bottomNavigationBar: _isSelectionMode && _selectedIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => _showBulkUpdateDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Mark ${_selectedIds.length} as ${_tabController.index == 0 ? 'Completed' : 'Pending'}',
                    style: AppTypography.h6.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStudentList(List<HomeworkSubmissionModel> students, bool isPending) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.check_circle_outline : Icons.hourglass_empty,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'All students have completed!' : 'No completions yet.',
              style: AppTypography.body2.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final isSelected = _selectedIds.contains(student.studentId);

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 8.h),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.lightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            onTap: _isSelectionMode 
                ? () => _toggleSelection(student.studentId)
                : () => _showStatusToggleDialog(student, isPending),
            onLongPress: () => _toggleSelection(student.studentId),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: isPending ? Colors.red.shade50 : Colors.green.shade50,
                  child: Text(
                    student.studentName.isNotEmpty ? student.studentName[0].toUpperCase() : '?',
                    style: AppTypography.body1.copyWith(
                      color: isPending ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            title: Text(student.studentName,
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text(
              isPending ? 'Pending' : 'Completed',
              style: AppTypography.caption.copyWith(
                color: isPending ? Colors.red : Colors.green,
              ),
            ),
            trailing: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    activeColor: AppColors.primary,
                    onChanged: (_) => _toggleSelection(student.studentId),
                  )
                : (isPending && student.parentPhone != null && student.parentPhone!.isNotEmpty
                    ? _CommunicationActions(
                        phone: student.parentPhone!,
                        studentName: student.studentName,
                        homeworkTitle: widget.homework.title,
                      )
                    : !isPending
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                        : null),
          ),
        );
      },
    );
  }

  void _showStatusToggleDialog(HomeworkSubmissionModel student, bool isPending) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Update Status', style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
          'Mark ${student.studentName}\'s homework as ${isPending ? 'Completed' : 'Pending'}?',
          style: AppTypography.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTypography.subtitle2.copyWith(color: AppColors.grey5E)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<HomeworkProvider>().updateSubmissionStatus(
                    homeworkId: widget.homework.id,
                    studentId: student.studentId,
                    status: isPending ? 'completed' : 'pending',
                  );
            },
            child: Text('Update', style: AppTypography.subtitle2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
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

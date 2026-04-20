import 'package:flutter/material.dart';
import '../../data/models/homework_model.dart';
import 'homework_student_tile.dart';

class HomeworkStudentList extends StatelessWidget {
  final List<HomeworkSubmissionModel> students;
  final bool isPending;
  final String homeworkId;
  final String homeworkTitle;

  const HomeworkStudentList({
    super.key,
    required this.students,
    required this.isPending,
    required this.homeworkId,
    required this.homeworkTitle,
  });

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: students.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
      itemBuilder: (context, index) {
        return HomeworkStudentTile(
          student: students[index],
          homeworkId: homeworkId,
          homeworkTitle: homeworkTitle,
        );
      },
    );
  }
}

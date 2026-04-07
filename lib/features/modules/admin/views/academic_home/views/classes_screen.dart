import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../../../providers/academic_provider.dart';
import 'classDivisionScreen.dart';

class ClassesScreen extends StatefulWidget {
  final String academicYearId;
  final String academicYear;

  const ClassesScreen({super.key, required this.academicYearId,required this.academicYear});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController classController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AcademicProvider>().fetchClasses());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [

          /// HEADER
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                ),

                const SizedBox(width: 10),

                const Text(
                  "Classes",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),

                const Spacer(),

                // ElevatedButton.icon(
                //   style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white),
                //   onPressed: _openAddDialog,
                //   icon: const Icon(Icons.add,
                //       color: Color(0xFF0F766E)),
                //   label: const Text("Add Class",
                //       style:
                //       TextStyle(color: Color(0xFF0F766E))),
                // )
              ],
            ),
          ),

          /// BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: provider.isClassLoading
                  ? const Center(
                  child: CircularProgressIndicator())
                  : GridView.builder(
                itemCount: provider.classesList.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.5,
                ),
                itemBuilder: (context, index) {
                  final doc = provider.classesList[index]; // Get the document
                  final data = doc.data() as Map<String, dynamic>;
                  final String classId = doc.id; // Unique Firestore ID
                  final String className = data['name'] ?? "";

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      // Navigate to the Divisions Screen
                      callNext(
                        ClassDivisionsScreen(
                          classId: classId,
                          className: className, academicYear: widget.academicYear, academicYearId: widget.academicYearId,
                        ),
                        context,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.class_, color: Color(0xFF0F766E), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              className,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Class"),
        content: TextField(
          controller: classController,
          decoration:
          const InputDecoration(labelText: "Class Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (classController.text.isEmpty) return;

              context.read<AcademicProvider>().addClass(
                classController.text.trim(),
              );

              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}
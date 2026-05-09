import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../providers/admin_provider.dart';
import 'classes_screen.dart';
import 'fee_management_main.dart';

class AcademicYearHomeScreen extends StatelessWidget {
  final String academicYearId;
  final String yearName;
  final String userId;
  final String userName;

  const AcademicYearHomeScreen({
    super.key,
    required this.academicYearId,
    required this.yearName,
    required this.userName,
    required this.userId
  });

  // Updated Theme Colors
  static const Color primaryBlue = Color(0xFF031937);
  static const Color secondaryBlue = Color(0xFF003865);
  static const Color bgColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          /// HEADER - Updated to Primary Blue
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              color: primaryBlue,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yearName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Session Dashboard",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
                childAspectRatio: 2.2, // Slightly adjusted for better text fit
                children: [
                  _moduleCard(
                    context,
                    title: "Classes",
                    icon: Icons.class_outlined,
                    onTap: () {
                      // Logic preserved: Pre-fetching divisions
                      context.read<AdminProvider>().fetchDivisionsGlobally(academicYearId);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassesScreen(
                            academicYearId: academicYearId,
                            academicYear: yearName,
                            userName: userName,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),

                  _moduleCard(
                    context,
                    title: "Fee Management",
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () {
                      // Logic preserved: Pre-fetching divisions
                      context.read<AdminProvider>().fetchDivisionsGlobally(academicYearId);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FeeManagementMain(
                            academicYearId: academicYearId,
                            academicYear: yearName,
                            userName: userName,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _moduleCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon uses Secondary Blue
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: secondaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 32, color: secondaryBlue),
            ),
            const Spacer(),
            Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)
            ),
            const SizedBox(height: 4),
            Text(
                "Manage $title settings",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)
            ),
          ],
        ),
      ),
    );
  }
}
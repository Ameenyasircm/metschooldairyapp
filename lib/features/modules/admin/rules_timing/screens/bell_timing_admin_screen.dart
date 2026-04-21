import 'package:flutter/material.dart';
import 'package:met_school/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class BellTimingAdminScreen extends StatefulWidget {
  const BellTimingAdminScreen({Key? key}) : super(key: key);

  @override
  State<BellTimingAdminScreen> createState() => _BellTimingAdminScreenState();
}

class _BellTimingAdminScreenState extends State<BellTimingAdminScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data from Firebase as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchBellTiming();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Bell Timing"),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title / Header
            const Text(
              "BELL TIMING",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // The Table Design
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    _buildTableHeader(),
                    // Generate Fixed Rows
                    ...List.generate(provider.regularList.length, (index) {
                      final regular = provider.regularList[index];
                      final friday = provider.fridayList.length > index
                          ? provider.fridayList[index]
                          : null;

                      return _buildTableRow(
                        context,
                        provider,
                        index,
                        regular.title,
                        regular.time,
                        friday?.time ?? "",
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Saturday Note from Image
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                // Only apply borders to left, right, and bottom so it merges with the table
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                children: const [
                  Text(
                    "Saturday",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Special Class and Training Programmes will be Conducted on Saturday",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "* Second saturday and fourth saturdays are holidays",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await provider.saveBellTiming();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Saved Successfully"),
                        backgroundColor: Color(0xFF0F766E),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Timings",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔷 TABLE HEADER
  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(
        color: Color(0xFF0F766E), // Admin Theme Color
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Bell / Period",
              textAlign: TextAlign.center,
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Regular day",
              textAlign: TextAlign.center,
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Friday",
              textAlign: TextAlign.center,
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  /// 🔷 TABLE ROW
  TableRow _buildTableRow(
      BuildContext context,
      AdminProvider provider,
      int index,
      String title,
      String regularTime,
      String fridayTime,
      ) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        // TITLE CELL
        _tableCell(
          context,
          title,
          isBold: true,
          onTap: () => _editDialog(
            context,
            "Edit Period Name",
            title,
                (val) => provider.updateTitle(index, val, isFriday: false),
          ),
        ),
        // REGULAR TIME CELL
        _tableCell(
          context,
          regularTime,
          onTap: () => _editDialog(
            context,
            "Edit Regular Time",
            regularTime,
                (val) => provider.updateTime(index, val, isFriday: false),
          ),
        ),
        // FRIDAY TIME CELL
        _tableCell(
          context,
          fridayTime,
          onTap: () => _editDialog(
            context,
            "Edit Friday Time",
            fridayTime,
                (val) => provider.updateTime(index, val, isFriday: true),
          ),
        ),
      ],
    );
  }

  /// 🔷 CELL UI
  Widget _tableCell(BuildContext context, String text,
      {required VoidCallback onTap, bool isBold = false}) {
    return TableRowInkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Text(
          text.isEmpty ? "-" : text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: text.isEmpty ? Colors.grey : Colors.black87,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /// 🔷 EDIT DIALOG
  void _editDialog(
      BuildContext context,
      String title,
      String initial,
      Function(String) onSave,
      ) {
    final controller = TextEditingController(text: initial);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Color(0xFF0F766E))),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0F766E)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}
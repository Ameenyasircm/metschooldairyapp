import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/admin_provider.dart';

class RulesAdminScreen extends StatefulWidget {
  const RulesAdminScreen({Key? key}) : super(key: key);

  @override
  State<RulesAdminScreen> createState() => _RulesAdminScreenState();
}

class _RulesAdminScreenState extends State<RulesAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchRules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Provider.of<AdminProvider>(context, listen: false).setIndex(0);

        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text("Rules and Regulations"),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        actions: [
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)))
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Title Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                "RULES AND REGULATIONS OF THE SCHOOL",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rules List
            Expanded(
              child: Container(
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
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.rulesList.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    return _buildRuleItem(
                        context, provider, index, provider.rulesList[index]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F766E),
                    side: const BorderSide(color: Color(0xFF0F766E)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  onPressed: () => _showRuleDialog(context, provider),
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Rule"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  onPressed: () async {
                    await provider.saveRules();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Rules Saved Successfully"),
                          backgroundColor: Color(0xFF0F766E),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 🔹 UI FOR A SINGLE RULE ROW
  Widget _buildRuleItem(
      BuildContext context, AdminProvider provider, int index, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet point
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 12),
            child: Icon(Icons.circle, size: 8, color: Colors.black87),
          ),
          // Rule Text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
          ),
          // Actions (Edit/Delete)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note, color: Color(0xFF0F766E)),
                tooltip: "Edit Rule",
                onPressed: () => _showRuleDialog(context, provider,
                    index: index, initialText: text),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: "Delete Rule",
                onPressed: () => _confirmDelete(context, provider, index),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// 🔹 ADD / EDIT DIALOG
  void _showRuleDialog(BuildContext context, AdminProvider provider,
      {int? index, String initialText = ""}) {
    final controller = TextEditingController(text: initialText);
    final isEditing = index != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isEditing ? "Edit Rule" : "Add New Rule",
          style: const TextStyle(color: Color(0xFF0F766E)),
        ),
        content: SizedBox(
          width: 500, // Make dialog wider for web/tablet
          child: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Enter rule text here...",
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0F766E)),
              ),
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
              if (controller.text.trim().isNotEmpty) {
                if (isEditing) {
                  provider.updateRule(index, controller.text.trim());
                } else {
                  provider.addRule(controller.text.trim());
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? "Update" : "Add"),
          )
        ],
      ),
    );
  }

  /// 🔹 CONFIRM DELETE DIALOG
  void _confirmDelete(BuildContext context, AdminProvider provider, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Rule?"),
        content: const Text("Are you sure you want to remove this rule?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteRule(index);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
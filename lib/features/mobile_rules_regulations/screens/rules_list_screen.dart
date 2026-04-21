import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_provider.dart';

class RulesUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text("Rules & Regulations",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0F766E),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.rulesList.isEmpty
          ? const Center(child: Text("No rules available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.rulesList.length,
        itemBuilder: (context, index) {
          final rule = provider.rulesList[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF0F766E).withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Bullet Number
                Container(
                  height: 28,
                  width: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(width: 10),

                /// 🔹 Rule Text
                Expanded(
                  child: Text(
                    rule,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
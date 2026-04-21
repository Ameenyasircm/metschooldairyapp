import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_provider.dart';

class BellTimingUserScreen extends StatelessWidget {
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
        title: const Text("School Timing",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0F766E),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.regularList.isEmpty
          ? const Center(child: Text("No timing available"))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: ListView.builder(
                itemCount: provider.regularList.length,
                itemBuilder: (context, index) {
                  final regular = provider.regularList[index];
                  final friday = provider.fridayList.length > index
                      ? provider.fridayList[index]
                      : null;

                  return _buildRow(
                    regular.title,
                    regular.time,
                    friday?.time ?? "",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔷 HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
              child: Center(
                  child: Text("Bell / Period",
                      style: TextStyle(color: Colors.white)))),
          Expanded(
              child: Center(
                  child: Text("Regular",
                      style: TextStyle(color: Colors.white)))),
          Expanded(
              child: Center(
                  child:
                  Text("Friday", style: TextStyle(color: Colors.white)))),
        ],
      ),
    );
  }

  /// 🔷 ROW
  Widget _buildRow(String title, String regular, String friday) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Center(child: Text(title))),
          Expanded(child: Center(child: Text(regular))),
          Expanded(child: Center(child: Text(friday))),
        ],
      ),
    );
  }
}
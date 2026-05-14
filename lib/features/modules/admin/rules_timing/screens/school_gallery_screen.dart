import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/admin_provider.dart';

class SchoolGalleryScreen extends StatelessWidget {
  const SchoolGalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primaryBlue = Color(0xFF031937);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Provider.of<AdminProvider>(context, listen: false).setIndex(0);

        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text("Gallary"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [
        ],
      ),
      body: Center(child: Text('Coming Soon')),
    );
  }
}

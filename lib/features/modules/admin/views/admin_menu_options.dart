import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';

class AdminMenuOptions extends StatelessWidget {
  const AdminMenuOptions({Key? key}) : super(key: key);

  void showQualificationDialog(BuildContext context) {

    AdminProvider provider =
    Provider.of<AdminProvider>(context, listen: false);

    provider.qualificationController.clear();

    /// FETCH QUALIFICATIONS
    provider.getQualifications();

    showDialog(
      context: context,

      builder: (context) {

        return Consumer<AdminProvider>(
          builder: (context, value, child) {

            return AlertDialog(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              title: const Text("Qualification Management"),

              content: SizedBox(
                width: 500,
                height: 500,

                child: Column(
                  children: [

                    /// TEXTFIELD
                    TextField(

                      controller:
                      value.qualificationController,

                      decoration: InputDecoration(

                        hintText: "Enter Qualification",

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),

                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(6),

                          child: ElevatedButton(

                            onPressed:
                            value.qualificationLoading
                                ? null
                                : () {
                              value.addQualification(
                                  context);
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF031937),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),

                            child: value.qualificationLoading
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text("Add"),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// TITLE
                    Row(
                      children: const [

                        Text(
                          "Added Qualifications",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 15),

                    /// LIST
                    Expanded(

                      child: value.qualificationFetchLoading

                          ? const Center(
                        child:
                        CircularProgressIndicator(),
                      )

                          : value.qualificationList.isEmpty

                          ? const Center(
                        child: Text(
                          "No Qualifications Added",
                        ),
                      )

                          : ListView.separated(

                        itemCount:
                        value.qualificationList.length,

                        separatorBuilder:
                            (context, index) {
                          return const SizedBox(
                              height: 10);
                        },

                        itemBuilder:
                            (context, index) {

                          final data =
                          value.qualificationList[index];

                          return Container(

                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                              BorderRadius.circular(
                                  12),
                            ),

                            child: Row(
                              children: [

                                Container(
                                  padding:
                                  const EdgeInsets.all(
                                      8),

                                  decoration: BoxDecoration(
                                    color:
                                    const Color(0xFF031937)
                                        .withOpacity(.1),

                                    borderRadius:
                                    BorderRadius.circular(
                                        10),
                                  ),

                                  child: const Icon(
                                    Icons.school_outlined,
                                    color:
                                    Color(0xFF031937),
                                    size: 18,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    data['qualification'] ??
                                        '',

                                    style: const TextStyle(
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),

              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF1F5F9),

      appBar: AppBar(
        leading: InkWell(
            onTap: (){
              Provider.of<AdminProvider>(context, listen: false).setIndex(0);
            },
            child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: const Text("Menu Options"),
        backgroundColor: const Color(0xFF031937),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(30),

        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [

            InkWell(

              onTap: () {
                showQualificationDialog(context);
              },

              borderRadius: BorderRadius.circular(18),

              child: Container(

                width: 260,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF031937).withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Color(0xFF031937),
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Qualifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF031937),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Add and manage qualifications",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: const [

                        Text(
                          "Manage",
                          style: TextStyle(
                            color: Color(0xFF031937),
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(width: 5),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF031937),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
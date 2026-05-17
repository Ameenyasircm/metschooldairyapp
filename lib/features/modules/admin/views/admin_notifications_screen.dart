import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../providers/admin_provider.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {

  /// COLORS
  static const Color blue90 = Color(0xff376090);
  static const Color darkBlue2 = Color(0xff031937);
  static const Color primary = Color(0xff001839);
  static const Color secondary = Color(0xff003366);
  static const Color third = Color(0xff0f5091);
  static const Color lightGreen = Color(0xff97F3E2);
  static const Color greenE1 = Color(0xffDAE5E1);

  final TextEditingController searchController =
  TextEditingController();

  String filterRole = "ALL";

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(

      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notification Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: third,

        onPressed: () {
          showSendNotificationDialog(context);
        },

        icon: const Icon(
          Icons.notifications_active,
          color: Colors.white,
        ),

        label: const Text(
          "Send Notification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// FILTER BAR
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 10,
                  )
                ],
              ),

              child: Row(
                children: [

                  /// SEARCH
                  Expanded(
                    child: Container(
                      height: 52,

                      decoration: BoxDecoration(
                        color: greenE1.withOpacity(.35),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      child: TextFormField(
                        controller: searchController,

                        onChanged: (value) {
                          setState(() {});
                        },

                        decoration: InputDecoration(
                          border: InputBorder.none,

                          hintText:
                          "Search notifications...",

                          prefixIcon: Icon(
                            Icons.search,
                            color: blue90,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  /// ROLE FILTER
                  Container(
                    width: 180,
                    height: 52,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),

                    decoration: BoxDecoration(
                      color: greenE1.withOpacity(.35),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),

                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filterRole,

                        items: [
                          "ALL",
                          "PARENT",
                          "TEACHER",
                        ].map((e) {

                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );

                        }).toList(),

                        onChanged: (value) {

                          filterRole = value!;
                          setState(() {});

                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("admin_notifications")
                    .orderBy(
                  "dateMillis",
                  descending: true,
                )
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {

                    return const Center(
                      child: Text(
                        "No Notifications Found",
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  final filteredDocs =
                  docs.where((doc) {

                    final data =
                    doc.data() as Map<String, dynamic>;

                    final title =
                    (data['title'] ?? "")
                        .toString()
                        .toLowerCase();

                    final message =
                    (data['message'] ?? "")
                        .toString()
                        .toLowerCase();

                    final role =
                    (data['role'] ?? "").toString();

                    final search =
                    searchController.text.toLowerCase();

                    final matchesSearch =
                        title.contains(search) ||
                            message.contains(search);

                    final matchesRole =
                    filterRole == "ALL"
                        ? true
                        : role == filterRole;

                    return matchesSearch &&
                        matchesRole;

                  }).toList();

                  return ListView.separated(

                    itemCount: filteredDocs.length,

                    separatorBuilder:
                        (context, index) {
                      return const SizedBox(height: 15);
                    },

                    itemBuilder: (context, index) {

                      final data =
                      filteredDocs[index].data()
                      as Map<String, dynamic>;

                      Timestamp? timeStamp =
                      data['createdAt'];

                      String date = "";

                      if (timeStamp != null) {

                        date = DateFormat(
                          "dd MMM yyyy • hh:mm a",
                        ).format(
                          timeStamp.toDate(),
                        );
                      }

                      return Container(

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(
                                  .04),
                              blurRadius: 10,
                            )
                          ],
                        ),

                        child: Row(
                          children: [

                            /// IMAGE
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(16),

                              child: data["image"] ==
                                  null ||
                                  data["image"] == ""

                                  ? Container(
                                height: 90,
                                width: 90,
                                color: greenE1,

                                child: Icon(
                                  Icons
                                      .notifications_active,
                                  color: blue90,
                                  size: 42,
                                ),
                              )

                                  : Image.network(
                                data["image"],
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 18),

                            /// DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [

                                  Row(
                                    children: [

                                      Expanded(
                                        child: Text(
                                          data["title"] ??
                                              "",

                                          style:
                                          const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                            color: primary,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding:
                                        const EdgeInsets
                                            .symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),

                                        decoration:
                                        BoxDecoration(
                                          color: third
                                              .withOpacity(
                                              .1),

                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              30),
                                        ),

                                        child: Text(
                                          data["role"] ??
                                              "",

                                          style:
                                          const TextStyle(
                                            color: third,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    data["message"] ?? "",

                                    maxLines: 2,

                                    overflow:
                                    TextOverflow
                                        .ellipsis,

                                    style: TextStyle(
                                      color: Colors
                                          .grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [

                                      Icon(
                                        Icons.schedule,
                                        color: blue90,
                                        size: 17,
                                      ),

                                      const SizedBox(
                                          width: 6),

                                      Text(
                                        "Sent on $date",

                                        style: TextStyle(
                                          color: Colors
                                              .grey
                                              .shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SEND DIALOG
  void showSendNotificationDialog(
      BuildContext context) {

    AdminProvider provider =
    Provider.of<AdminProvider>(
      context,
      listen: false,
    );

    provider.notificationTitleController.clear();
    provider.notificationMessageController.clear();

    provider.selectedNotificationRole =
    "PARENT";

    showDialog(
      context: context,

      builder: (context) {

        return Consumer<AdminProvider>(
          builder: (context, value, child) {

            return AlertDialog(

              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(24),
              ),

              contentPadding:
              const EdgeInsets.all(25),

              content: SizedBox(
                width: 550,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Send Notification",

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                        FontWeight.bold,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// ROLE
                    const Text(
                      "Send To",

                      style: TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: value
                          .selectedNotificationRole,

                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                        greenE1.withOpacity(.35),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          BorderSide.none,
                        ),
                      ),

                      items: [
                        "PARENT",
                        "TEACHER",
                      ].map((e) {

                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );

                      }).toList(),

                      onChanged: (val) {

                        value.selectedNotificationRole =
                        val!;

                        value.notifyListeners();
                      },
                    ),

                    const SizedBox(height: 18),

                    /// TITLE
                    TextFormField(
                      controller:
                      value
                          .notificationTitleController,

                      decoration: InputDecoration(
                        hintText:
                        "Notification Title",

                        filled: true,

                        fillColor:
                        greenE1.withOpacity(.35),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// MESSAGE
                    TextFormField(
                      controller:
                      value
                          .notificationMessageController,

                      maxLines: 5,

                      decoration: InputDecoration(
                        hintText:
                        "Notification Message",

                        filled: true,

                        fillColor:
                        greenE1.withOpacity(.35),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// BUTTONS
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,

                      children: [

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text(
                            "Cancel",
                          ),
                        ),

                        const SizedBox(width: 12),

                        ElevatedButton(
                          onPressed:
                          value
                              .notificationLoading

                              ? null

                              : () async {

                            await value
                                .sendAdminNotification(
                              context,
                            );

                            Navigator.pop(
                                context);
                          },

                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            third,

                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 25,
                              vertical: 16,
                            ),
                          ),

                          child:
                          value.notificationLoading

                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                              Colors.white,
                            ),
                          )

                              : const Text(
                            "SEND",

                            style: TextStyle(
                              color:
                              Colors.white,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
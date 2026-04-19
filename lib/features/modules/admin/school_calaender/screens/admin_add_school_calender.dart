import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
// Assuming these are your internal imports:
import '../../../../../providers/admin_provider.dart';

class AdminCalendarWebScreen extends StatefulWidget {
  @override
  State<AdminCalendarWebScreen> createState() => _AdminCalendarWebScreenState();
}

class _AdminCalendarWebScreenState extends State<AdminCalendarWebScreen> {
  // --- Theme Colors ---
  static const Color primary = Color(0xff00796B);
  static const Color secondary = Color(0xff006B5F);
  static const Color bgColor = Color(0xFFF5F7F9); // Soft background for web

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Provider.of<AdminProvider>(context, listen: false).setIndex(0);

        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: Text(
          "School Calendar Admin",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primary,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Wider padding for web
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                return SfCalendar(
                  view: CalendarView.month,
                  headerStyle: CalendarHeaderStyle(
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  viewHeaderStyle: ViewHeaderStyle(
                    dayTextStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  todayHighlightColor: primary,

                  /// 🔥 CLICK DATE → OPEN ADD FORM
                  onTap: (details) {
                    if (details.date != null) {
                      provider.setDate(details.date!);
                      showAddEventDialog(context);
                    }
                  },

                  /// 🔥 CUSTOM CELL UI
                  monthCellBuilder: (context, details) {
                    final events = provider.getEventsByDate(details.date);
                    final isToday = details.date.day == DateTime.now().day &&
                        details.date.month == DateTime.now().month &&
                        details.date.year == DateTime.now().year;

                    return Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isToday ? primary.withOpacity(0.05) : Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 6, bottom: 2),
                            child: Text(
                              "${details.date.day}",
                              style: TextStyle(
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                color: isToday ? primary : Colors.grey.shade800,
                              ),
                            ),
                          ),

                          // Event Chips
                          ...events.take(2).map((e) => Container(
                            margin: EdgeInsets.only(bottom: 2, left: 4, right: 4),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.title,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),

                          // "+X more" indicator
                          if (events.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(left: 6, top: 2),
                              child: Text(
                                "+${events.length - 2} more",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                              ),
                            )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void showAddEventDialog(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450, // Slightly wider for web
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.event_note, color: primary),
                    SizedBox(width: 10),
                    Text(
                      "Add New Event",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                Divider(height: 30),

                // Selected Date Display
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: secondary),
                      SizedBox(width: 8),
                      Text(
                        provider.selectedDate != null
                            ? DateFormat('EEEE, dd MMMM yyyy').format(provider.selectedDate!)
                            : "",
                        style: TextStyle(fontWeight: FontWeight.bold, color: secondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Title Input
                TextField(
                  controller: provider.titleCt,
                  decoration: InputDecoration(
                    labelText: "Event Title",
                    labelStyle: TextStyle(color: primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primary, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Description Input
                TextField(
                  controller: provider.descCt,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(color: primary),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primary, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Action Buttons
                Consumer<AdminProvider>(
                  builder: (context, value, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: Text("Cancel"),
                        ),
                        SizedBox(width: 12),
                        value.isLoading
                            ? CircularProgressIndicator(color: primary)
                            : ElevatedButton(
                          onPressed: () {
                            value.addEvent(context);
                            // Assuming addEvent handles closing the dialog.
                            // If not, add Navigator.pop(context) here.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Save Event"),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
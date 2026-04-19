import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:met_school/providers/admin_provider.dart';
import 'package:met_school/core/constants/app_padding.dart';
import 'package:met_school/core/constants/app_radius.dart';
import 'package:met_school/core/constants/app_spacing.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';
import '../../../admin/school_calaender/models/school_event_model.dart';

class SchoolCalendarMobileScreen extends StatefulWidget {
  const SchoolCalendarMobileScreen({super.key});

  @override
  State<SchoolCalendarMobileScreen> createState() =>
      _SchoolCalendarMobileScreenState();
}

class _SchoolCalendarMobileScreenState extends State<SchoolCalendarMobileScreen> {
  DateTime? selectedDate;

  // --- Theme Colors ---
  static const Color primary = Color(0xff00796B);
  static const Color secondary = Color(0xff006B5F);
  static const Color bgColor = Color(0xFFF9FAFB);

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
        title: const Text(
          "School Calendar",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return Container(
            color: Colors.white,
            child: SfCalendar(
              view: CalendarView.month,
              headerStyle: const CalendarHeaderStyle(
                textStyle: TextStyle(
                  fontSize: 18,
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

              /// 🔥 TAP → SHOW EVENTS
              onTap: (details) {
                if (details.date == null) return;

                setState(() => selectedDate = details.date);

                final events = provider.getEventsByDate(details.date!);
                showEventBottomSheet(context, details.date!, events);
              },

              /// 🔥 CUSTOM CELL UI (CLEAN & THEMED)
              monthCellBuilder: (context, details) {
                final date = details.date;
                final now = DateTime.now();

                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;

                final isSelected = selectedDate != null &&
                    date.year == selectedDate!.year &&
                    date.month == selectedDate!.month &&
                    date.day == selectedDate!.day;

                final events = provider.getEventsByDate(date);

                return Container(
                  margin: const EdgeInsets.all(1.5),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primary.withOpacity(0.08)
                        : isToday
                        ? primary.withOpacity(0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : isToday
                          ? primary.withOpacity(0.5)
                          : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DATE
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 2),
                        child: Text(
                          "${date.day}",
                          style: TextStyle(
                            fontWeight: (isToday || isSelected)
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12,
                            color: isToday ? primary : Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 2),

                      /// EVENTS PREVIEW
                      ...events.take(2).map((e) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          e.title,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),

                      if (events.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            "+${events.length - 2} more",
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: secondary,
                            ),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void showEventBottomSheet(
      BuildContext context, DateTime date, List<SchoolEventModel> events) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Transparent to show rounded corners
      isScrollControlled: true,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// DRAG HANDLE
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event, color: primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              /// NO DATA STATE
              if (events.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "No events scheduled for this day.",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                ),

              /// EVENT LIST
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// INDICATOR LINE
                            Container(
                              width: 6,
                              decoration: const BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(12),
                                ),
                              ),
                            ),

                            /// CONTENT
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (e.description.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        e.description,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
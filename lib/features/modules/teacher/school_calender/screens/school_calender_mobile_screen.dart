import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/providers/admin_provider.dart';
import '../../../admin/school_calaender/models/school_event_model.dart';

class SchoolCalendarMobileScreen extends StatefulWidget {
  const SchoolCalendarMobileScreen({super.key});

  @override
  State<SchoolCalendarMobileScreen> createState() =>
      _SchoolCalendarMobileScreenState();
}

class _SchoolCalendarMobileScreenState
    extends State<SchoolCalendarMobileScreen> {
  final CalendarController _calendarController = CalendarController();

  DateTime _focusedMonth =
  DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false)
            .fetchEvents());
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    _calendarController.displayDate =
        DateTime(_focusedMonth.year, _focusedMonth.month);
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    _calendarController.displayDate =
        DateTime(_focusedMonth.year, _focusedMonth.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          "School Calendar",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [

              /// 🔷 MODERN HEADER
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                      AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [

                    _navBtn(Icons.chevron_left, _previousMonth),

                    Column(
                      children: [
                        Text(
                          DateFormat('MMMM')
                              .format(_focusedMonth),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy')
                              .format(_focusedMonth),
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),

                    _navBtn(Icons.chevron_right, _nextMonth),
                  ],
                ),
              ),

              /// 🔷 CALENDAR CARD
              Expanded(
                child: Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.05),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: SfCalendar(
                    controller: _calendarController,
                    view: CalendarView.month,
                    headerHeight: 0,
                    todayHighlightColor: AppColors.primary,

                    viewHeaderStyle: ViewHeaderStyle(
                      backgroundColor:
                      Colors.grey.shade50,
                      dayTextStyle: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    onTap: (details) {
                      if (details.date == null) return;

                      if (details.date!.month !=
                          _focusedMonth.month ||
                          details.date!.year !=
                              _focusedMonth.year) return;

                      _showDateEventsSheet(
                          context,
                          details.date!,
                          provider);
                    },

                    onViewChanged: (details) {
                      final mid = details.visibleDates[
                      details.visibleDates.length ~/ 2];

                      if (mid.month !=
                          _focusedMonth.month ||
                          mid.year !=
                              _focusedMonth.year) {
                        setState(() {
                          _focusedMonth =
                              DateTime(mid.year, mid.month);
                        });
                      }
                    },

                    monthCellBuilder: (context, details) {
                      final date = details.date;
                      final now = DateTime.now();

                      final isCurrentMonth =
                          date.month ==
                              _focusedMonth.month &&
                              date.year ==
                                  _focusedMonth.year;

                      final isToday =
                          date.day == now.day &&
                              date.month == now.month &&
                              date.year == now.year;

                      final events = isCurrentMonth
                          ? provider.getEventsByDate(date)
                          : [];

                      return Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: !isCurrentMonth
                              ? Colors.grey.shade50
                              : isToday
                              ? AppColors.primary
                              .withOpacity(0.12)
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday
                                ? AppColors.primary
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: isCurrentMonth
                            ? Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            /// Day
                            Padding(
                              padding:
                              const EdgeInsets.all(4),
                              child: Text(
                                "${date.day}",
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  color: isToday
                                      ? AppColors.primary
                                      : Colors.black,
                                ),
                              ),
                            ),

                            /// Events
                            ...events.take(2).map(
                                  (e) => Container(
                                margin:
                                const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 1),
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                  AppColors.primary,
                                  borderRadius:
                                  BorderRadius
                                      .circular(6),
                                ),
                                child: Text(
                                  e.title,
                                  style:
                                  const TextStyle(
                                    fontSize: 8,
                                    color:
                                    Colors.white,
                                  ),
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                ),
                              ),
                            ),

                            if (events.length > 2)
                              Padding(
                                padding:
                                const EdgeInsets
                                    .only(left: 4),
                                child: Text(
                                  "+${events.length - 2}",
                                  style: TextStyle(
                                      fontSize: 8,
                                      color:
                                      AppColors.primary),
                                ),
                              )
                          ],
                        )
                            : const SizedBox(),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔹 NAV BUTTON
  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  /// 🔹 EVENTS BOTTOM SHEET
  void _showDateEventsSheet(
      BuildContext context,
      DateTime date,
      AdminProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final events = provider.getEventsByDate(date);

        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              if (events.isEmpty)
                const Text("No events"),

              ...events.map((e) => Container(
                margin:
                const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary
                          .withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.title),
                    )
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}
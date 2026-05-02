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

                      final isSunday = date.weekday == DateTime.sunday;

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
                              : isSunday
                              ? AppColors.errorRed.withOpacity(0.05)
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday
                                ? AppColors.primary.withOpacity(0.5)
                                : isSunday
                                ? AppColors.errorRed.withOpacity(0.3)
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
                              padding: const EdgeInsets.only(
                                  left: 5, top: 4),
                              child: Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: isToday
                                    ?  BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                )
                                    : isSunday
                                    ? BoxDecoration(
                                  color: AppColors.errorRed.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                )
                                    : null,
                                child: Text(
                                  "${date.day}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isToday
                                        ? Colors.white
                                        : isSunday
                                        ? AppColors.errorRed
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),

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

                            if (events.length > (isSunday && events.isEmpty ? 1 : 2))
                              Padding(
                                padding:
                                const EdgeInsets
                                    .only(left: 4),
                                child: Text(
                                  "+${events.length - (isSunday && events.isEmpty ? 1 : 2)}",
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
// ── Events Bottom Sheet (view only) ──
  void _showDateEventsSheet(
      BuildContext context, DateTime date, AdminProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65),
          padding:
          const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(date),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy').format(date),
                          style:  TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade400),
                  ),
                ],
              ),

              Divider(height: 24, color: Colors.grey.shade200),

              Consumer<AdminProvider>(
                builder: (ctx, prov, _) {
                  final events = prov.getEventsByDate(date);

                  if (events.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.event_busy,
                              size: 44, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            "No events for this day",
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: events.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final event = events[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.04),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Accent bar
                                Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(10)),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (event.description != null &&
                                            event.description!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            event.description!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

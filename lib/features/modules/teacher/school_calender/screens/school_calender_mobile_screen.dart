import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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

  static const Color primary   = Color(0xff00796B);
  static const Color secondary = Color(0xff006B5F);
  static const Color bgColor   = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchEvents());
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
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "School Calendar",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Month Navigator ──
              Container(
                color: primary,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 16, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: _previousMonth,
                    ),
                    Column(
                      children: [
                        Text(
                          DateFormat('MMMM').format(_focusedMonth),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy').format(_focusedMonth),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    _NavButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: _nextMonth,
                    ),
                  ],
                ),
              ),

              // ── Calendar ──
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SfCalendar(
                    controller: _calendarController,
                    view: CalendarView.month,
                    // Hide built-in header — we have our own
                    headerHeight: 0,
                    viewHeaderHeight: 36,
                    viewHeaderStyle: ViewHeaderStyle(
                      backgroundColor: Colors.grey.shade50,
                      dayTextStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Color(0xff00796B),
                      ),
                    ),
                    todayHighlightColor: primary,
                    // Hide leading/trailing days from other months
                    // showTrailingAndLeadingDates: false,
                    onTap: (details) {
                      if (details.date == null) return;
                      // Ignore taps on empty (other-month) cells
                      if (details.date!.month != _focusedMonth.month ||
                          details.date!.year != _focusedMonth.year) return;
                      _showDateEventsSheet(context, details.date!, provider);
                    },
                    onViewChanged: (details) {
                      // Keep _focusedMonth in sync if user swipes
                      if (details.visibleDates.isNotEmpty) {
                        final mid = details.visibleDates[
                        details.visibleDates.length ~/ 2];
                        if (mid.month != _focusedMonth.month ||
                            mid.year != _focusedMonth.year) {
                          setState(() {
                            _focusedMonth = DateTime(mid.year, mid.month);
                          });
                        }
                      }
                    },
                    monthCellBuilder: (context, details) {
                      final date = details.date;
                      final now  = DateTime.now();

                      // Grey out dates from other months
                      final isCurrentMonth =
                          date.month == _focusedMonth.month &&
                              date.year == _focusedMonth.year;

                      final isToday = date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;

                      final events = isCurrentMonth
                          ? provider.getEventsByDate(date)
                          : <SchoolEventModel>[];

                      return Container(
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: !isCurrentMonth
                              ? Colors.grey.shade50
                              : isToday
                              ? primary.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isToday
                                ? primary.withOpacity(0.5)
                                : Colors.grey.shade200,
                            width: isToday ? 1.5 : 1,
                          ),
                        ),
                        child: isCurrentMonth
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day number
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, top: 4),
                              child: Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: isToday
                                    ? const BoxDecoration(
                                  color: primary,
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
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Event chips
                            ...events.take(2).map(
                                  (e) => Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                    bottom: 2, left: 3, right: 3),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius:
                                  BorderRadius.circular(3),
                                ),
                                child: Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (events.length > 2)
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 4),
                                child: Text(
                                  "+${events.length - 2}",
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: secondary,
                                  ),
                                ),
                              ),
                          ],
                        )
                        // Other-month cell — blank
                            : const SizedBox.shrink(),
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
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today,
                        color: primary, size: 18),
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
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
                            color: primary.withOpacity(0.04),
                            border: Border.all(
                                color: primary.withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Accent bar
                                Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: primary,
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

// ── Nav Arrow Button ──
class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withOpacity(0.35)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 22),
      ),
    );
  }
}
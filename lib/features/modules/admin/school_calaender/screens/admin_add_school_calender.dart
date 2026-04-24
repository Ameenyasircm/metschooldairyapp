import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  static const Color bgColor = Color(0xFFF5F7F9);

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchEvents());
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  /// Returns only the days belonging to the focused month (no overflow)
  List<DateTime?> _buildMonthDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
    DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);

    // weekday: Monday=1 ... Sunday=7 → we want Sunday=0 offset
    int startOffset = firstDay.weekday % 7; // Sunday-based week

    final List<DateTime?> cells = [];
    // Leading empty cells
    for (int i = 0; i < startOffset; i++) {
      cells.add(null);
    }
    // Actual days
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(

        leading: IconButton(
          onPressed: () {
            Provider.of<AdminProvider>(context, listen: false).setIndex(0);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "School Calendar Admin",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            // ← compact width so it doesn't stretch full screen
            constraints: BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Consumer<AdminProvider>(
                    builder: (context, provider, child) {
                      final cells = _buildMonthDays();
                      final today = DateTime.now();
        
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Month Navigator Header ──
                          _buildMonthHeader(),
        
                          SizedBox(height: 16),
        
                          // ── Weekday Labels ──
                          _buildWeekdayRow(),
        
                          SizedBox(height: 8),
        
                          // ── Calendar Grid ──
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: cells.length,
                            itemBuilder: (context, index) {
                              final date = cells[index];
                              if (date == null) {
                                return SizedBox.shrink(); // empty slot
                              }
        
                              final events = provider.getEventsByDate(date);
                              final isToday = date.day == today.day &&
                                  date.month == today.month &&
                                  date.year == today.year;
        
                              return GestureDetector(
                                onTap: () {
                                  provider.setDate(date);
                                  showDateEventsDialog(context, date, provider); // ← changed
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? primary.withOpacity(0.08)
                                        : Colors.grey.shade50,
                                    border: Border.all(
                                      color: isToday
                                          ? primary.withOpacity(0.5)
                                          : Colors.grey.shade200,
                                      width: isToday ? 1.5 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(                          // ← clips overflow content
                                    borderRadius: BorderRadius.circular(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,        // ← don't stretch
                                      children: [
                                        // Day Number
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5, left: 7),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            alignment: Alignment.center,
                                            decoration: isToday
                                                ? BoxDecoration(
                                              color: primary,
                                              shape: BoxShape.circle,
                                            )
                                                : null,
                                            child: Text(
                                              "${date.day}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isToday ? Colors.white : Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                        ),
        
                                        SizedBox(height: 2),
        
                                        // Event Chips — only show what fits, rest shown as "+X more"
                                        ...events.take(2).map(
                                              (e) => Container(
                                            margin: EdgeInsets.only(bottom: 2, left: 4, right: 4),
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),  // ← reduced vertical padding
                                            decoration: BoxDecoration(
                                              color: primary,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              e.title,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
        
                                        // +X more indicator
                                        if (events.length > 2)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5, top: 1),
                                            child: Text(
                                              "+${events.length - 2} more",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: secondary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Month Header with Arrow Navigation ──
  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Month Arrow
        _ArrowButton(
          icon: Icons.chevron_left_rounded,
          onTap: _previousMonth,
          color: primary,
        ),

        // Month & Year Title
        Column(
          children: [
            Text(
              DateFormat('MMMM').format(_focusedMonth),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              DateFormat('yyyy').format(_focusedMonth),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Next Month Arrow
        _ArrowButton(
          icon: Icons.chevron_right_rounded,
          onTap: _nextMonth,
          color: primary,
        ),
      ],
    );
  }

  // ── Weekday Row (Sun–Sat) ──
  Widget _buildWeekdayRow() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: d == 'Sun' || d == 'Sat'
                    ? Colors.red.shade300
                    : Colors.grey.shade600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  // ── Add Event Dialog ──
  void showAddEventDialog(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            ? DateFormat('EEEE, dd MMMM yyyy')
                            .format(provider.selectedDate!)
                            : "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: secondary),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
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

  void showDateEventsDialog(BuildContext context, DateTime date, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            constraints: BoxConstraints(maxHeight: 520),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.calendar_today, color: primary, size: 18),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE').format(date),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy').format(date),
                            style: TextStyle(
                              fontSize: 18,
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

                SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: 12),

                // ── Events List ──
                Consumer<AdminProvider>(
                  builder: (context44, prov, _) {
                    final events = prov.getEventsByDate(date);

                    if (events.isEmpty) {
                      // Empty state
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.event_busy,
                                  size: 40, color: Colors.grey.shade300),
                              SizedBox(height: 10),
                              Text(
                                "No events for this day",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Events list
                    return Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: events.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8),
                        itemBuilder: (contextss, index) {
                          final event = events[index];
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.05),
                              border: Border.all(color: primary.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      if (event.description != null &&
                                          event.description!.isNotEmpty) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          event.description!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                                // Optional: Delete button
                                IconButton(
                                  onPressed: () {
                                    prov.deleteEvent(context,event); // call your delete method
                                  },
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.red.shade300, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),

                // ── Add New Event Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // close list dialog
                      showAddEventDialog(context); // open add form
                    },
                    icon: Icon(Icons.add, size: 18),
                    label: Text(
                      "Add New Event",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Reusable Arrow Button Widget ──
class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _hovered ? widget.color : widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.icon,
            color: _hovered ? Colors.white : widget.color,
            size: 22,
          ),
        ),
      ),
    );
  }
}
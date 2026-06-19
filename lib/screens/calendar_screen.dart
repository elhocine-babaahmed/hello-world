import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';
import 'day_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [

          // ── Month calendar ─────────────────────────────────────────────
          TableCalendar<EventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) => provider.getEventsForDay(day),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DayScreen(date: selectedDay)),
              );
            },
            onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Color(0xFF3A2A18),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF3A2A18)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF3A2A18)),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 12, color: Color(0xFF8C7257)),
              weekendStyle: TextStyle(fontSize: 12, color: Color(0xFFB5564A)),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Color(0xFF3A2A18), fontSize: 13),
              weekendTextStyle: const TextStyle(color: Color(0xFFB5564A), fontSize: 13),
              todayDecoration: BoxDecoration(
                color: const Color(0xFFD9952F).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFD9952F),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: Color(0xFF3A2A18), fontWeight: FontWeight.w700, fontSize: 13),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              markersMaxCount: 4,
              markerSize: 6,
              markerMargin: const EdgeInsets.symmetric(horizontal: 0.8),
            ),
            // Custom marker builder — one dot per event type color
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                // Deduplicate by type so one dot per type
                final seen = <EventType>{};
                final unique = events.where((e) => seen.add(e.type)).toList();
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: unique.take(4).map((e) => Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 0.8),
                      decoration: BoxDecoration(
                        color: e.type.color,
                        shape: BoxShape.circle,
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE8DCC2)),

          // ── Legend ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 14,
              runSpacing: 8,
              children: EventType.values
                  .map((type) => _LegendDot(type: type))
                  .toList(),
            ),
          ),

          // ── Tap hint ────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Tap any day to view or add entries',
              style: TextStyle(fontSize: 12, color: Color(0xFFB6A488)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final EventType type;
  const _LegendDot({required this.type});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: type.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(type.label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF8C7257))),
      ],
    );
  }
}
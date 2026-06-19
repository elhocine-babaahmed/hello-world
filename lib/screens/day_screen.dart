import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../providers/hives_provider.dart';
import 'day_entry_sheet.dart';

class DayScreen extends StatelessWidget {
  final DateTime date;
  const DayScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsProvider>().getEventsForDay(date);

    return Scaffold(
      appBar: AppBar(title: Text(_formatDate(date))),
      body: events.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined, size: 52, color: Color(0xFFD8C8AC)),
                  SizedBox(height: 14),
                  Text(
                    'No entries for this day',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap the button below to log an entry',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8C7257)),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _EventTile(
                  event: events[index],
                  onDelete: () =>
                      context.read<EventsProvider>().deleteEvent(events[index].id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DayEntrySheet(date: date)),
        ),
        backgroundColor: const Color(0xFF3A2A18),
        foregroundColor: const Color(0xFFFBF3E2),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add entry'),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final dow = days[d.weekday - 1];
    return '$dow ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EventTile extends StatelessWidget {
  final EventModel event;
  final VoidCallback onDelete;
  const _EventTile({required this.event, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hive = context.read<HivesProvider>().getById(event.hiveId);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent strip by event type
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: event.type.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Header row
                    Row(
                      children: [
                        Icon(event.type.icon, size: 15, color: event.type.color),
                        const SizedBox(width: 6),
                        Text(
                          event.type.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: event.type.color,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          hive?.displayName ?? 'Unknown hive',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8C7257)),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFFFFFDF8),
                                title: const Text('Delete entry?'),
                                content: const Text(
                                  'This entry will be permanently removed.',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF8C7257)),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete', style: TextStyle(color: Color(0xFFB5564A))),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) onDelete();
                          },
                          child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFD8C8AC)),
                        ),
                      ],
                    ),

                    // Detail chips
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (event.colonyStrength != null)
                          _Chip(label: 'Colony: ${event.colonyStrength!.label}'),
                        if (event.queenStatus != null)
                          _Chip(label: 'Queen: ${event.queenStatus!.label}'),
                        if (event.broodQuality != null)
                          _Chip(label: 'Brood: ${event.broodQuality!.label}'),
                        if (event.foodStores != null)
                          _Chip(label: 'Food: ${event.foodStores!.label}'),
                        if (event.feedingAmountL != null)
                          _Chip(
                            label: 'Fed: ${event.feedingAmountL}L'
                                '${event.syrupRatio != null ? " (${event.syrupRatio})" : ""}',
                          ),
                        if ((event.framesAdded ?? 0) > 0)
                          _Chip(label: '+${event.framesAdded} frame${event.framesAdded == 1 ? "" : "s"}'),
                      ],
                    ),

                    // Notes
                    if (event.notes != null && event.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.notes!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF3A2A18), height: 1.4),
                      ),
                    ],

                    // Next action reminder tag
                    if (event.nextActionDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5564A).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFB5564A).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_outlined, size: 12, color: Color(0xFFB5564A)),
                            const SizedBox(width: 4),
                            Text(
                              'Next: ${_formatShortDate(event.nextActionDate!)}',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFFB5564A)),
                            ),
                          ],
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
  }

  String _formatShortDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF8C7257))),
    );
  }
}
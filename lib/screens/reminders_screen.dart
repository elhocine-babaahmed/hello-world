import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/reminders_provider.dart';
import '../providers/hives_provider.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<RemindersProvider>().reminders;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: reminders.isEmpty
          ? const _EmptyRemindersState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _ReminderTile(reminder: reminders[index]);
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────

class _ReminderTile extends StatelessWidget {
  final ReminderModel reminder;

  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final hive = context.read<HivesProvider>().getById(reminder.hiveId);
    final isOverdue = reminder.daysUntilDue < 0;
    final accentColor = isOverdue ? const Color(0xFFB5564A) : const Color(0xFFD9952F);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reminder.completed ? const Color(0xFFE8DCC2) : accentColor.withOpacity(0.3),
          width: reminder.completed ? 1 : 1.5,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent strip
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: reminder.completed ? const Color(0xFFB6A488) : accentColor,
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
                        Icon(
                          Icons.event_outlined,
                          size: 16,
                          color: reminder.completed ? const Color(0xFFB6A488) : accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reminder.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: reminder.completed
                                  ? const Color(0xFFB6A488)
                                  : const Color(0xFF3A2A18),
                              decoration: reminder.completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Text(
                          hive?.displayName ?? 'Unknown',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8C7257)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Due date label
                    Text(
                      reminder.dueDateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: reminder.completed
                            ? const Color(0xFFB6A488)
                            : (isOverdue ? const Color(0xFFB5564A) : const Color(0xFFD9952F)),
                        fontWeight: isOverdue && !reminder.completed ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            if (!reminder.completed)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<String>(
                  onSelected: (action) {
                    final provider = context.read<RemindersProvider>();
                    if (action == 'complete') {
                      provider.completeReminder(reminder.id);
                    } else if (action == 'snooze3') {
                      provider.snoozeReminder(reminder.id, 3);
                    } else if (action == 'snooze7') {
                      provider.snoozeReminder(reminder.id, 7);
                    } else if (action == 'delete') {
                      provider.deleteReminder(reminder.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 16, color: Color(0xFF6E8B5E)),
                          SizedBox(width: 8),
                          Text('Mark complete'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'snooze3',
                      child: Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Color(0xFFD9952F)),
                          SizedBox(width: 8),
                          Text('Snooze 3 days'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'snooze7',
                      child: Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Color(0xFFD9952F)),
                          SizedBox(width: 8),
                          Text('Snooze 7 days'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: Color(0xFFB5564A)),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert, size: 18, color: Color(0xFFD8C8AC)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRemindersState extends StatelessWidget {
  const _EmptyRemindersState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 56, color: Color(0xFFD8C8AC)),
          SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18)),
          ),
          SizedBox(height: 6),
          Text(
            'Reminders appear here once you log a "next action" date',
            style: TextStyle(fontSize: 13, color: Color(0xFF8C7257)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class RemindersProvider extends ChangeNotifier {
  final List<ReminderModel> _reminders = [];

  List<ReminderModel> get reminders {
    final list = List<ReminderModel>.from(_reminders);
    // Sort by dueDate ascending (soonest first), then by completed status
    list.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1; // Active reminders first
      }
      return a.dueDate.compareTo(b.dueDate);
    });
    return list;
  }

  // Get upcoming reminders (not completed, within N days)
  List<ReminderModel> getUpcomingReminders(int count, {int withinDays = 30}) {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: withinDays));
    return reminders
        .where((r) => !r.completed && r.dueDate.isBefore(cutoff))
        .take(count)
        .toList();
  }

  // Get overdue reminders (dueDate is in the past)
  List<ReminderModel> get overdueReminders {
    final now = DateTime.now();
    return _reminders
        .where((r) => !r.completed && r.dueDate.isBefore(now))
        .toList();
  }

  ReminderModel? getById(String id) {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void addReminder(ReminderModel reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void updateReminder(ReminderModel updated) {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index == -1) return;
    _reminders[index] = updated;
    notifyListeners();
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Mark reminder as complete
  void completeReminder(String id) {
    final reminder = getById(id);
    if (reminder != null) {
      updateReminder(reminder.copyWith(completed: true));
    }
  }

  // Snooze reminder by N days
  void snoozeReminder(String id, int days) {
    final reminder = getById(id);
    if (reminder != null) {
      updateReminder(reminder.copyWith(
        dueDate: reminder.dueDate.add(Duration(days: days)),
      ));
    }
  }
}

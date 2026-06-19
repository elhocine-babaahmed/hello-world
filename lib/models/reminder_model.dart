import 'package:flutter/material.dart';

class ReminderModel {
  final String id;
  final int hiveId;
  final String title;
  final DateTime dueDate;
  final bool completed;

  const ReminderModel({
    required this.id,
    required this.hiveId,
    required this.title,
    required this.dueDate,
    this.completed = false,
  });

  // Helper to calculate days until due
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  // Human-readable due date label
  String get dueDateLabel {
    final days = daysUntilDue;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 0) return '${days.abs()} days ago';
    return 'In $days days';
  }

  // copyWith — returns a new ReminderModel with only the specified fields changed
  ReminderModel copyWith({
    String? id,
    int? hiveId,
    String? title,
    DateTime? dueDate,
    bool? completed,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      hiveId: hiveId ?? this.hiveId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
    );
  }
}

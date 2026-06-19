import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventsProvider extends ChangeNotifier {
  final List<EventModel> _events = [];

  List<EventModel> get events => List.from(_events);

  List<EventModel> getEventsForDay(DateTime day) {
    return _events
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .toList();
  }

  List<EventModel> getEventsForHive(int hiveId) {
    final list = _events.where((e) => e.hiveId == hiveId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<EventModel> getRecentEvents(int count) {
    final sorted = List<EventModel>.from(_events)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  // Used by Phase 4 to build the Reminders list
  List<EventModel> get eventsWithNextAction =>
      _events.where((e) => e.nextActionDate != null).toList();

  // Stats helpers used by HiveDetailScreen
  int feedingCountForHive(int hiveId) =>
      getEventsForHive(hiveId).where((e) => e.feedingAmountL != null).length;

  double totalLitresForHive(int hiveId) =>
      getEventsForHive(hiveId)
          .fold(0, (sum, e) => sum + (e.feedingAmountL ?? 0));

  int totalFramesForHive(int hiveId) =>
      getEventsForHive(hiveId)
          .fold(0, (sum, e) => sum + (e.framesAdded ?? 0));

  int splitCountForHive(int hiveId) =>
      getEventsForHive(hiveId)
          .where((e) => e.type == EventType.split)
          .length;

  EventModel? lastInspectionForHive(int hiveId) {
    final inspections = getEventsForHive(hiveId)
        .where((e) => e.type == EventType.inspection)
        .toList();
    return inspections.isEmpty ? null : inspections.first;
  }

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
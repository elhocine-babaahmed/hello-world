import 'package:flutter/material.dart';
import '../models/hive_model.dart';

class HivesProvider extends ChangeNotifier {
  // Private list — only mutated through the defined methods below.
  // Sorted by id ascending so Hive #1 is always first.
  final List<HiveModel> _hives = [];

  // ── Getters ───────────────────────────────────────────────────────────────

  List<HiveModel> get hives {
    final list = List<HiveModel>.from(_hives);
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  int get hiveCount     => _hives.length;
  int get strongCount   => _hives.where((h) => h.status == HiveStatus.strong).length;
  int get mediumCount   => _hives.where((h) => h.status == HiveStatus.medium).length;
  int get weakCount     => _hives.where((h) => h.status == HiveStatus.weak).length;

  // Returns a single hive by id, or null if not found.
  HiveModel? getById(int id) {
    try {
      return _hives.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  // Auto-increment: next id = highest existing id + 1, or 1 if list is empty.
  int get _nextId => _hives.isEmpty ? 1 : _hives.map((h) => h.id).reduce((a, b) => a > b ? a : b) + 1;

  // ── Write operations ──────────────────────────────────────────────────────

  void addHive({
    required DateTime createdDate,
    required HiveOrigin origin,
    HiveStatus status = HiveStatus.medium,
    String? notes,
  }) {
    _hives.add(HiveModel(
      id: _nextId,
      createdDate: createdDate,
      origin: origin,
      status: status,
      notes: notes,
    ));
    notifyListeners();
  }

  void updateHive(HiveModel updated) {
    final index = _hives.indexWhere((h) => h.id == updated.id);
    if (index == -1) return;
    _hives[index] = updated;
    notifyListeners();
  }

  void deleteHive(int id) {
    _hives.removeWhere((h) => h.id == id);
    notifyListeners();
  }
}
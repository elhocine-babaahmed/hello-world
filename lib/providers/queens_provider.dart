import 'package:flutter/material.dart';
import '../models/queen_model.dart';

class QueensProvider extends ChangeNotifier {
  final List<QueenModel> _queens = [];
  int _nextId = 1;

  List<QueenModel> get queens => List.from(_queens);

  QueenModel? getById(int id) {
    try {
      return _queens.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  List<QueenModel> getQueensForHive(int hiveId) {
    return _queens.where((q) => q.hiveId == hiveId).toList();
  }

  QueenModel? getActiveQueenForHive(int hiveId) {
    final hiveQueens = getQueensForHive(hiveId);
    try {
      return hiveQueens.firstWhere((q) => q.isActive);
    } catch (_) {
      return null;
    }
  }

  void addQueen(QueenModel queen) {
    _queens.add(queen.copyWith(id: _nextId++));
    notifyListeners();
  }

  void updateQueen(QueenModel updated) {
    final index = _queens.indexWhere((q) => q.id == updated.id);
    if (index == -1) return;
    _queens[index] = updated;
    notifyListeners();
  }

  void deleteQueen(int id) {
    _queens.removeWhere((q) => q.id == id);
    notifyListeners();
  }

  void recordQueenSighting(int queenId) {
    final queen = getById(queenId);
    if (queen != null) {
      updateQueen(queen.copyWith(lastSeenDate: DateTime.now()));
    }
  }
}

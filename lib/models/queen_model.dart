import 'package:flutter/material.dart';

class QueenModel {
  final int id;
  final int hiveId;
  final int? originHiveId; // Which hive was she raised from
  final DateTime introducedDate;
  final DateTime? lastSeenDate;
  final String? notes;

  const QueenModel({
    required this.id,
    required this.hiveId,
    this.originHiveId,
    required this.introducedDate,
    this.lastSeenDate,
    this.notes,
  });

  bool get isActive => lastSeenDate == null || DateTime.now().difference(lastSeenDate!).inDays < 180;

  QueenModel copyWith({
    int? id,
    int? hiveId,
    int? originHiveId,
    DateTime? introducedDate,
    DateTime? lastSeenDate,
    String? notes,
  }) {
    return QueenModel(
      id: id ?? this.id,
      hiveId: hiveId ?? this.hiveId,
      originHiveId: originHiveId ?? this.originHiveId,
      introducedDate: introducedDate ?? this.introducedDate,
      lastSeenDate: lastSeenDate ?? this.lastSeenDate,
      notes: notes ?? this.notes,
    );
  }
}

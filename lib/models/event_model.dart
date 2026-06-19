import 'package:flutter/material.dart';

enum EventType {
  inspection,
  feeding,
  frameAdded,
  split,
  queenReplacement,
  swarm,
  customNote,
}

enum ColonyStrength { veryWeak, weak, medium, strong, veryStrong }
enum QueenStatus    { seen, notSeen, newQueen, queenCellPresent }
enum BroodQuality   { poor, average, good, excellent }
enum FoodStores     { low, medium, high }

extension EventTypeExt on EventType {
  String get label {
    switch (this) {
      case EventType.inspection:       return 'Inspection';
      case EventType.feeding:          return 'Feeding';
      case EventType.frameAdded:       return 'Frame Added';
      case EventType.split:            return 'Split';
      case EventType.queenReplacement: return 'Queen Replacement';
      case EventType.swarm:            return 'Swarm';
      case EventType.customNote:       return 'Custom Note';
    }
  }

  Color get color {
    switch (this) {
      case EventType.inspection:       return const Color(0xFF6E8B5E);
      case EventType.feeding:          return const Color(0xFFD9952F);
      case EventType.frameAdded:       return const Color(0xFF5B8BB5);
      case EventType.split:            return const Color(0xFF8B5B8B);
      case EventType.queenReplacement: return const Color(0xFFB5564A);
      case EventType.swarm:            return const Color(0xFFB5564A);
      case EventType.customNote:       return const Color(0xFF8C7257);
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.inspection:       return Icons.fact_check_outlined;
      case EventType.feeding:          return Icons.water_drop_outlined;
      case EventType.frameAdded:       return Icons.grid_view_outlined;
      case EventType.split:            return Icons.call_split;
      case EventType.queenReplacement: return Icons.swap_horiz_outlined;
      case EventType.swarm:            return Icons.swipe_outlined;
      case EventType.customNote:       return Icons.note_outlined;
    }
  }
}

extension ColonyStrengthExt on ColonyStrength {
  String get label {
    switch (this) {
      case ColonyStrength.veryWeak:   return 'Very Weak';
      case ColonyStrength.weak:       return 'Weak';
      case ColonyStrength.medium:     return 'Medium';
      case ColonyStrength.strong:     return 'Strong';
      case ColonyStrength.veryStrong: return 'Very Strong';
    }
  }
}

extension QueenStatusExt on QueenStatus {
  String get label {
    switch (this) {
      case QueenStatus.seen:             return 'Seen';
      case QueenStatus.notSeen:          return 'Not Seen';
      case QueenStatus.newQueen:         return 'New Queen';
      case QueenStatus.queenCellPresent: return 'Queen Cell Present';
    }
  }
}

extension BroodQualityExt on BroodQuality {
  String get label {
    switch (this) {
      case BroodQuality.poor:      return 'Poor';
      case BroodQuality.average:   return 'Average';
      case BroodQuality.good:      return 'Good';
      case BroodQuality.excellent: return 'Excellent';
    }
  }
}

extension FoodStoresExt on FoodStores {
  String get label {
    switch (this) {
      case FoodStores.low:    return 'Low';
      case FoodStores.medium: return 'Medium';
      case FoodStores.high:   return 'High';
    }
  }
}

class EventModel {
  final String id;
  final int hiveId;
  final EventType type;
  final DateTime date;

  final ColonyStrength? colonyStrength;
  final QueenStatus?    queenStatus;
  final BroodQuality?   broodQuality;
  final FoodStores?     foodStores;

  final double?  feedingAmountL;
  final String?  syrupRatio;
  final int?     framesAdded;

  final String?       notes;
  final List<String>  photoPaths;
  final DateTime?     nextActionDate;

  const EventModel({
    required this.id,
    required this.hiveId,
    required this.type,
    required this.date,
    this.colonyStrength,
    this.queenStatus,
    this.broodQuality,
    this.foodStores,
    this.feedingAmountL,
    this.syrupRatio,
    this.framesAdded,
    this.notes,
    this.photoPaths = const [],
    this.nextActionDate,
  });

  // copyWith — returns a new EventModel with only the specified fields changed
  EventModel copyWith({
    String? id,
    int? hiveId,
    EventType? type,
    DateTime? date,
    ColonyStrength? colonyStrength,
    QueenStatus? queenStatus,
    BroodQuality? broodQuality,
    FoodStores? foodStores,
    double? feedingAmountL,
    String? syrupRatio,
    int? framesAdded,
    String? notes,
    List<String>? photoPaths,
    DateTime? nextActionDate,
  }) {
    return EventModel(
      id: id ?? this.id,
      hiveId: hiveId ?? this.hiveId,
      type: type ?? this.type,
      date: date ?? this.date,
      colonyStrength: colonyStrength ?? this.colonyStrength,
      queenStatus: queenStatus ?? this.queenStatus,
      broodQuality: broodQuality ?? this.broodQuality,
      foodStores: foodStores ?? this.foodStores,
      feedingAmountL: feedingAmountL ?? this.feedingAmountL,
      syrupRatio: syrupRatio ?? this.syrupRatio,
      framesAdded: framesAdded ?? this.framesAdded,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
      nextActionDate: nextActionDate ?? this.nextActionDate,
    );
  }
}

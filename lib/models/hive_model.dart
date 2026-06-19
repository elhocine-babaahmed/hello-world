// The core data model for the entire app.
// Every field is final — HiveModel is immutable.
// To change a field, use copyWith() to produce a new instance.
// Phase 5 adds Hive (the package) serialization annotations here.

enum HiveOrigin { newColony, split, capturedSwarm }

enum HiveStatus { strong, medium, weak }

class HiveModel {
  final int id;
  final DateTime createdDate;
  final HiveOrigin origin;
  final HiveStatus status;

  // Lineage — present in the model now, wired in Phase 6.
  final int? parentHiveId;
  final List<int> childHiveIds;

  // Queen — present now, populated in Phase 7.
  final int? currentQueenId;

  // Free notes about the hive overall (not per inspection).
  final String? notes;

  // Photo file paths — populated in Phase 6.
  final List<String> photosOutside;
  final List<String> photosInside;

  const HiveModel({
    required this.id,
    required this.createdDate,
    required this.origin,
    this.status = HiveStatus.medium,
    this.parentHiveId,
    this.childHiveIds = const [],
    this.currentQueenId,
    this.notes,
    this.photosOutside = const [],
    this.photosInside = const [],
  });

  // copyWith — returns a new HiveModel with only the specified fields changed.
  // Every field not mentioned falls back to its current value via ??.
  HiveModel copyWith({
    HiveStatus? status,
    int? parentHiveId,
    List<int>? childHiveIds,
    int? currentQueenId,
    String? notes,
    List<String>? photosOutside,
    List<String>? photosInside,
    bool clearParent = false,  // explicit flag — same null-vs-absent problem as mood in Quill
  }) {
    return HiveModel(
      id: id,
      createdDate: createdDate,
      origin: origin,
      status: status ?? this.status,
      parentHiveId: clearParent ? null : (parentHiveId ?? this.parentHiveId),
      childHiveIds: childHiveIds ?? this.childHiveIds,
      currentQueenId: currentQueenId ?? this.currentQueenId,
      notes: notes ?? this.notes,
      photosOutside: photosOutside ?? this.photosOutside,
      photosInside: photosInside ?? this.photosInside,
    );
  }

  // ── Display helpers ───────────────────────────────────────────────────────

  String get displayName => 'Hive #$id';

  String get originLabel {
    switch (origin) {
      case HiveOrigin.newColony:     return 'New Colony';
      case HiveOrigin.split:         return 'Split';
      case HiveOrigin.capturedSwarm: return 'Captured Swarm';
    }
  }

  String get statusLabel {
    switch (status) {
      case HiveStatus.strong: return 'Strong';
      case HiveStatus.medium: return 'Medium';
      case HiveStatus.weak:   return 'Weak';
    }
  }
}
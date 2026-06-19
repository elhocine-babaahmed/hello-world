import 'package:flutter/material.dart';

class SettingsModel {
  final List<double> feedingPresets; // Default: [0.5, 1.0, 1.5]
  final bool notificationsEnabled;
  final bool darkMode;

  const SettingsModel({
    this.feedingPresets = const [0.5, 1.0, 1.5],
    this.notificationsEnabled = false,
    this.darkMode = false,
  });

  SettingsModel copyWith({
    List<double>? feedingPresets,
    bool? notificationsEnabled,
    bool? darkMode,
  }) {
    return SettingsModel(
      feedingPresets: feedingPresets ?? this.feedingPresets,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

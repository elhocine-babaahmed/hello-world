import 'package:flutter/material.dart';
import '../models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsModel _settings = const SettingsModel();

  SettingsModel get settings => _settings;

  List<double> get feedingPresets => _settings.feedingPresets;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get darkMode => _settings.darkMode;

  void updateFeedingPresets(List<double> presets) {
    _settings = _settings.copyWith(feedingPresets: presets);
    notifyListeners();
  }

  void toggleNotifications() {
    _settings = _settings.copyWith(notificationsEnabled: !_settings.notificationsEnabled);
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    notifyListeners();
  }
}

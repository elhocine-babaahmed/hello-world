import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsGroup(
            label: 'Feeding presets',
            children: [
              ...settings.feedingPresets.map((preset) => 
                _SettingsTile(
                  icon: Icons.water_drop_outlined,
                  title: '${preset.toStringAsFixed(1)} L',
                  trailing: const Icon(Icons.check, color: Color(0xFF6E8B5E)),
                )
              ).toList(),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsGroup(
            label: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'In-app reminders only',
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (_) => context.read<SettingsProvider>().toggleNotifications(),
                  activeColor: const Color(0xFF3A2A18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsGroup(
            label: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark mode',
                trailing: Switch(
                  value: settings.darkMode,
                  onChanged: (_) => context.read<SettingsProvider>().toggleDarkMode(),
                  activeColor: const Color(0xFF3A2A18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsGroup(
            label: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                trailing: const Text('1.0.0', style: TextStyle(fontSize: 13, color: Color(0xFF8C7257))),
              ),
              _SettingsTile(
                icon: Icons.favorite_outline,
                title: 'Built with Flutter',
                trailing: const Icon(Icons.chevron_right, color: Color(0xFFD8C8AC)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _SettingsGroup({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, letterSpacing: 1.0, color: Color(0xFFB6A488), fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8DCC2))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  const _SettingsTile({required this.icon, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEAE0D5), width: 0.5))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8C7257)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A18)))),
          trailing,
        ],
      ),
    );
  }
}

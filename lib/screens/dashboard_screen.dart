import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/hives_provider.dart';
import '../providers/events_provider.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hives  = context.watch<HivesProvider>();
    final events = context.watch<EventsProvider>();
    final recent = events.getRecentEvents(5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [

          // ── Summary cards ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Total Hives', value: '${hives.hiveCount}', color: const Color(0xFFD9952F))),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(label: 'Strong', value: '${hives.strongCount}', color: const Color(0xFF6E8B5E))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Medium', value: '${hives.mediumCount}', color: const Color(0xFFD9952F))),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(label: 'Weak', value: '${hives.weakCount}', color: const Color(0xFFB5564A))),
            ],
          ),

          const SizedBox(height: 24),

          // ── Upcoming tasks — stub until Phase 4 ─────────────────────────
          const _SectionLabel(label: 'UPCOMING TASKS'),
          const SizedBox(height: 10),
          const _EmptyCard(icon: Icons.event_available_outlined, text: 'No reminders yet — add a next action date when logging an entry'),

          const SizedBox(height: 24),

          // ── Recent activity ──────────────────────────────────────────────
          const _SectionLabel(label: 'RECENT ACTIVITY'),
          const SizedBox(height: 10),
          recent.isEmpty
              ? const _EmptyCard(icon: Icons.history, text: 'Nothing logged yet')
              : Column(
                  children: recent.map((event) {
                    final hive = context.read<HivesProvider>().getById(event.hiveId);
                    return _ActivityTile(event: event, hiveName: hive?.displayName ?? '');
                  }).toList(),
                ),

          const SizedBox(height: 24),

          // ── Quick actions ────────────────────────────────────────────────
          const _SectionLabel(label: 'QUICK ACTIONS'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionButton(icon: Icons.fact_check_outlined, label: 'New Inspection', onTap: () {}),
              _QuickActionButton(icon: Icons.water_drop_outlined, label: 'Feed Hive', onTap: () {}),
              _QuickActionButton(icon: Icons.add_box_outlined, label: 'Add Hive', onTap: () {}),
              _QuickActionButton(icon: Icons.call_split, label: 'Create Split', onTap: () {}),
            ],
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  final EventModel event;
  final String hiveName;
  const _ActivityTile({required this.event, required this.hiveName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: event.type.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$hiveName — ${event.type.label}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF3A2A18), fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            _formatDate(event.date),
            style: const TextStyle(fontSize: 11, color: Color(0xFFB6A488)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}

// ── Shared private widgets ───────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8C7257))),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.w700, color: Color(0xFF8C7257)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFFB6A488)),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFFB6A488))),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8DCC2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFFD9952F)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF3A2A18), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
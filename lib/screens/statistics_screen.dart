import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hives_provider.dart';
import '../providers/events_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hives = context.watch<HivesProvider>();
    final events = context.watch<EventsProvider>();

    final sortedByFeeding = hives.hives.toList()..sort((a, b) => 
      events.totalLitresForHive(b.id).compareTo(events.totalLitresForHive(a.id)));
    
    final sortedBySplits = hives.hives.toList()..sort((a, b) => 
      events.splitCountForHive(b.id).compareTo(events.splitCountForHive(a.id)));

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            title: 'Colony Health Summary',
            child: Row(
              children: [
                Expanded(child: _HealthStat(label: 'Strong', count: hives.strongCount, color: const Color(0xFF6E8B5E))),
                const SizedBox(width: 8),
                Expanded(child: _HealthStat(label: 'Medium', count: hives.mediumCount, color: const Color(0xFFD9952F))),
                const SizedBox(width: 8),
                Expanded(child: _HealthStat(label: 'Weak', count: hives.weakCount, color: const Color(0xFFB5564A))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StatCard(
            title: 'Most Fed Hives',
            child: Column(
              children: sortedByFeeding.take(5).map((hive) => _StatRow(
                label: hive.displayName,
                value: '${events.totalLitresForHive(hive.id).toStringAsFixed(1)}L',
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _StatCard(
            title: 'Most Productive Hives',
            child: Column(
              children: sortedBySplits.take(5).map((hive) => _StatRow(
                label: hive.displayName,
                value: '${events.splitCountForHive(hive.id)} splits',
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _StatCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HealthStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _HealthStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8C7257))),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF3A2A18)))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFD9952F))),
        ],
      ),
    );
  }
}

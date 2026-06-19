import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../models/event_model.dart';
import '../providers/hives_provider.dart';
import '../providers/events_provider.dart';
import 'add_edit_hive_screen.dart';
import 'day_entry_sheet.dart';

class HiveDetailScreen extends StatelessWidget {
  final int hiveId;
  const HiveDetailScreen({super.key, required this.hiveId});

  Future<void> _confirmDelete(BuildContext context, HiveModel hive) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFFDF8),
        title: Text('Delete ${hive.displayName}?'),
        content: const Text(
          'All events for this hive will also be removed. This cannot be undone.',
          style: TextStyle(fontSize: 14, color: Color(0xFF8C7257)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFB5564A))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<HivesProvider>().deleteHive(hiveId);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hive   = context.watch<HivesProvider>().getById(hiveId);
    final events = context.watch<EventsProvider>().getEventsForHive(hiveId);

    if (hive == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hive not found.')),
      );
    }

    final evProvider = context.read<EventsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(hive.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add entry',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DayEntrySheet(
                  date: DateTime.now(),
                  preselectedHiveId: hiveId,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit hive',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditHiveScreen(hive: hive)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFB5564A)),
            tooltip: 'Delete hive',
            onPressed: () => _confirmDelete(context, hive),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [

          // ── General info ──────────────────────────────────────────────────
          _DetailSection(
            title: 'General Information',
            child: Column(
              children: [
                _Row(label: 'Hive ID', value: hive.displayName),
                _Row(label: 'Created', value: _fmtFull(hive.createdDate)),
                _Row(label: 'Origin', value: hive.originLabel),
                _Row(
                  label: 'Status',
                  valueWidget: _StatusBadge(status: hive.status),
                ),
                if (hive.parentHiveId != null)
                  _Row(label: 'Split from', value: 'Hive #${hive.parentHiveId}'),
                if (hive.childHiveIds.isNotEmpty)
                  _Row(
                    label: 'Split into',
                    value: hive.childHiveIds.map((id) => 'Hive #$id').join(', '),
                  ),
                if (hive.notes != null && hive.notes!.isNotEmpty)
                  _Row(label: 'Notes', value: hive.notes!),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Statistics ────────────────────────────────────────────────────
          _DetailSection(
            title: 'Statistics',
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Feedings',
                    value: '${evProvider.feedingCountForHive(hiveId)}',
                    sub: '${evProvider.totalLitresForHive(hiveId).toStringAsFixed(1)}L total',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: 'Frames',
                    value: '${evProvider.totalFramesForHive(hiveId)}',
                    sub: 'added',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: 'Splits',
                    value: '${evProvider.splitCountForHive(hiveId)}',
                    sub: 'produced',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Timeline ──────────────────────────────────────────────────────
          _DetailSection(
            title: 'Timeline',
            child: events.isEmpty
                ? const _PlaceholderContent(
                    icon: Icons.history,
                    text: 'No events yet',
                    sub: 'Tap + in the top bar to log an entry',
                  )
                : Column(
                    children: events.map((event) => _TimelineTile(event: event)).toList(),
                  ),
          ),

          const SizedBox(height: 16),

          // ── Photos placeholder ─────────────────────────────────────────────
          _DetailSection(
            title: 'Photos',
            child: Row(
              children: [
                Expanded(
                  child: _PhotoCategoryCard(
                    label: 'Outside',
                    icon: Icons.door_front_door_outlined,
                    count: hive.photosOutside.length,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PhotoCategoryCard(
                    label: 'Inside',
                    icon: Icons.grid_view_outlined,
                    count: hive.photosInside.length,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  String _fmtFull(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TimelineTile extends StatelessWidget {
  final EventModel event;
  const _TimelineTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date column
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Text(
                  '${event.date.day}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3A2A18)),
                ),
                Text(
                  _month(event.date),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF8C7257)),
                ),
              ],
            ),
          ),
          // Dot + line
          Column(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: event.type.color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 44, color: const Color(0xFFE8DCC2)),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.type.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: event.type.color,
                  ),
                ),
                if (event.colonyStrength != null)
                  _MiniChip(label: event.colonyStrength!.label),
                if (event.feedingAmountL != null)
                  _MiniChip(label: '${event.feedingAmountL}L syrup'),
                if ((event.framesAdded ?? 0) > 0)
                  _MiniChip(label: '+${event.framesAdded} frames'),
                if (event.notes != null && event.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      event.notes!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8C7257)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _month(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[d.month - 1];
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  const _MiniChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8C7257))),
    );
  }
}

// ── Shared private widgets ──────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.w700, color: Color(0xFF8C7257)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8DCC2)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  const _Row({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8C7257))),
          ),
          Expanded(
            child: valueWidget ??
                Text(value ?? '—',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final HiveStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    String emoji;
    switch (status) {
      case HiveStatus.strong: color = const Color(0xFF6E8B5E); label = 'Strong'; emoji = '🟢';
      case HiveStatus.medium: color = const Color(0xFFD9952F); label = 'Medium'; emoji = '🟡';
      case HiveStatus.weak:   color = const Color(0xFFB5564A); label = 'Weak';   emoji = '🔴';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text('$emoji $label', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  final IconData icon;
  final String text;
  final String sub;
  const _PlaceholderContent({required this.icon, required this.text, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFFD8C8AC)),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
        const SizedBox(height: 4),
        Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFFB6A488))),
      ],
    );
  }
}

class _PhotoCategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  const _PhotoCategoryCard({required this.label, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF8C7257)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
          Text('$count photo${count == 1 ? '' : 's'}', style: const TextStyle(fontSize: 11, color: Color(0xFFB6A488))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _StatCard({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFD9952F))),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFFB6A488))),
        ],
      ),
    );
  }
}
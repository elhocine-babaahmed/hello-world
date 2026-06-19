import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hives_provider.dart';
import 'hive_detail_screen.dart';
import 'add_edit_hive_screen.dart';

class HivesScreen extends StatelessWidget {
  const HivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this screen whenever HivesProvider notifies.
    final provider = context.watch<HivesProvider>();
    final hives = provider.hives;

    return Scaffold(
      appBar: AppBar(title: const Text('Hives')),
      body: hives.isEmpty
          ? const _EmptyHivesState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: hives.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _HiveCard(
                  hive: hives[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HiveDetailScreen(hiveId: hives[index].id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditHiveScreen()),
        ),
        backgroundColor: const Color(0xFF3A2A18),
        foregroundColor: const Color(0xFFFBF3E2),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add hive'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hive card — shown in the list
// ─────────────────────────────────────────────────────────────────────────────

class _HiveCard extends StatelessWidget {
  final HiveModel hive;
  final VoidCallback onTap;

  const _HiveCard({required this.hive, required this.onTap});

  // Each status gets its own color — used for the left border accent.
  Color get _statusColor {
    switch (hive.status) {
      case HiveStatus.strong: return const Color(0xFF6E8B5E);
      case HiveStatus.medium: return const Color(0xFFD9952F);
      case HiveStatus.weak:   return const Color(0xFFB5564A);
    }
  }

  String get _statusEmoji {
    switch (hive.status) {
      case HiveStatus.strong: return '🟢';
      case HiveStatus.medium: return '🟡';
      case HiveStatus.weak:   return '🔴';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DCC2)),
          // The left border accent is the visual "health indicator" of the card.
          // We achieve it by layering a 4px left border on top of the standard border.
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left status accent strip
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Title row ───────────────────────────────────────
                      Row(
                        children: [
                          Text(
                            hive.displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A2A18),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$_statusEmoji ${hive.statusLabel}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ── Info row ────────────────────────────────────────
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today_outlined,
                            label: _formatDate(hive.createdDate),
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.info_outline,
                            label: hive.originLabel,
                          ),
                          // Parent hive link — only shown if this is a split
                          if (hive.parentHiveId != null) ...[
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.call_split,
                              label: 'From #${hive.parentHiveId}',
                            ),
                          ],
                        ],
                      ),

                      // ── Last inspection placeholder ─────────────────────
                      const SizedBox(height: 8),
                      const Text(
                        'Last inspection: —',
                        style: TextStyle(fontSize: 12, color: Color(0xFFB6A488)),
                      ),

                    ],
                  ),
                ),
              ),

              // Chevron
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Color(0xFFD8C8AC)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF8C7257)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8C7257))),
        ],
      ),
    );
  }
}

class _EmptyHivesState extends StatelessWidget {
  const _EmptyHivesState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hive_outlined, size: 56, color: Color(0xFFD8C8AC)),
          SizedBox(height: 16),
          Text('No hives yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
          SizedBox(height: 6),
          Text('Add your first hive to start tracking it', style: TextStyle(fontSize: 13, color: Color(0xFF8C7257))),
        ],
      ),
    );
  }
}
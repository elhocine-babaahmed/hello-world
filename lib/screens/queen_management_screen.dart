import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/queen_model.dart';
import '../providers/queens_provider.dart';
import '../providers/hives_provider.dart';

class QueenManagementScreen extends StatelessWidget {
  final int hiveId;
  const QueenManagementScreen({super.key, required this.hiveId});

  @override
  Widget build(BuildContext context) {
    final hive = context.read<HivesProvider>().getById(hiveId);
    final queens = context.watch<QueensProvider>().getQueensForHive(hiveId);

    return Scaffold(
      appBar: AppBar(title: Text('Queen History - ${hive?.displayName ?? "Hive"}')),
      body: queens.isEmpty
          ? const Center(child: Text('No queen records yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: queens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _QueenCard(queen: queens[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addQueen(context, hiveId),
        backgroundColor: const Color(0xFF3A2A18),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Queen'),
      ),
    );
  }

  void _addQueen(BuildContext context, int hiveId) {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    var introducedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFFDF8),
        title: const Text('Add New Queen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Queen ID (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<QueensProvider>().addQueen(QueenModel(
                id: 0,
                hiveId: hiveId,
                introducedDate: introducedDate,
                notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
              ));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _QueenCard extends StatelessWidget {
  final QueenModel queen;
  const _QueenCard({required this.queen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DCC2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.royalty, size: 16, color: const Color(0xFFD9952F)),
              const SizedBox(width: 8),
              Text('Introduced', style: const TextStyle(fontSize: 11, color: Color(0xFFB6A488))),
              const Spacer(),
              Text(_formatDate(queen.introducedDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
            ],
          ),
          if (queen.lastSeenDate != null) ...[const SizedBox(height: 8), Row(children: [
            Icon(Icons.visibility, size: 16, color: const Color(0xFF6E8B5E)),
            const SizedBox(width: 8),
            Text('Last Seen', style: const TextStyle(fontSize: 11, color: Color(0xFFB6A488))),
            const Spacer(),
            Text(_formatDate(queen.lastSeenDate!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18))),
          ])],
          if (queen.notes != null && queen.notes!.isNotEmpty) ...[const SizedBox(height: 8), Text(queen.notes!, style: const TextStyle(fontSize: 12, color: Color(0xFF8C7257)))],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

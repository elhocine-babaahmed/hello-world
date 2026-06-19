import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hives_provider.dart';

// Dual-purpose: passing null (or omitting `hive`) = create mode.
//               passing an existing HiveModel = edit mode.
class AddEditHiveScreen extends StatefulWidget {
  final HiveModel? hive;
  const AddEditHiveScreen({super.key, this.hive});

  @override
  State<AddEditHiveScreen> createState() => _AddEditHiveScreenState();
}

class _AddEditHiveScreenState extends State<AddEditHiveScreen> {
  late TextEditingController _notesController;

  late DateTime _createdDate;
  late HiveOrigin _origin;
  late HiveStatus _status;

  bool get _isEditing => widget.hive != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill all fields from the existing hive in edit mode,
    // or use sensible defaults in create mode.
    _notesController = TextEditingController(text: widget.hive?.notes ?? '');
    _createdDate = widget.hive?.createdDate ?? DateTime.now();
    _origin = widget.hive?.origin ?? HiveOrigin.newColony;
    _status = widget.hive?.status ?? HiveStatus.medium;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Opens a Material date picker and updates _createdDate on selection.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _createdDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Wrap the date picker in a Theme to match our honey color scheme.
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFD9952F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _createdDate = picked);
  }

  void _save() {
    final provider = context.read<HivesProvider>();

    if (_isEditing) {
      // Edit mode: update the existing hive, preserving all fields we didn't touch.
      provider.updateHive(widget.hive!.copyWith(
        status: _status,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ));
    } else {
      // Create mode: add a brand-new hive with an auto-generated ID.
      provider.addHive(
        createdDate: _createdDate,
        origin: _origin,
        status: _status,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final nextId = context.read<HivesProvider>().hiveCount + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit ${widget.hive!.displayName}' : 'Add Hive'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Color(0xFF3A2A18), fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Hive ID ─────────────────────────────────────────────────────
          // In create mode, shown as a preview of what the ID will be.
          // In edit mode, shown as a read-only label (ID never changes).
          _FormSection(
            label: 'Hive ID',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EDE0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8DCC2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hive_outlined, size: 18, color: Color(0xFF8C7257)),
                  const SizedBox(width: 10),
                  Text(
                    _isEditing ? widget.hive!.displayName : 'Hive #$nextId (auto-assigned)',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8C7257)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Created date ────────────────────────────────────────────────
          // Disabled in edit mode — you can't change when a hive was started.
          _FormSection(
            label: 'Created Date',
            child: GestureDetector(
              onTap: _isEditing ? null : _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: _isEditing ? const Color(0xFFF5EDE0) : const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8DCC2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF8C7257)),
                    const SizedBox(width: 10),
                    Text(_formatDate(_createdDate), style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A18))),
                    const Spacer(),
                    if (!_isEditing)
                      const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFB6A488)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Origin ──────────────────────────────────────────────────────
          // Disabled in edit mode — origin is set at creation, not changed later.
          _FormSection(
            label: 'Origin',
            child: Column(
              children: HiveOrigin.values.map((origin) {
                final isSelected = _origin == origin;
                final isDisabled = _isEditing;
                return GestureDetector(
                  onTap: isDisabled ? null : () => setState(() => _origin = origin),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD9952F).withOpacity(0.10) : const Color(0xFFFFFDF8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _originIcon(origin),
                          size: 18,
                          color: isSelected ? const Color(0xFFD9952F) : const Color(0xFF8C7257),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _originLabel(origin),
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? const Color(0xFFD9952F) : const Color(0xFF3A2A18),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, size: 18, color: Color(0xFFD9952F)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ── Status ──────────────────────────────────────────────────────
          // Editable in both create and edit mode.
          _FormSection(
            label: 'Colony Status',
            child: Row(
              children: HiveStatus.values.map((status) {
                final isSelected = _status == status;
                final color = _statusColor(status);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(right: status != HiveStatus.weak ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.12) : const Color(0xFFFFFDF8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE8DCC2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(_statusEmoji(status), style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(
                            _statusLabel(status),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? color : const Color(0xFF8C7257),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ── Notes ────────────────────────────────────────────────────────
          _FormSection(
            label: 'Notes (optional)',
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A18)),
              decoration: InputDecoration(
                hintText: 'General notes about this hive…',
                hintStyle: const TextStyle(color: Color(0xFFB6A488), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFFFFDF8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE8DCC2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE8DCC2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD9952F), width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  IconData _originIcon(HiveOrigin o) {
    switch (o) {
      case HiveOrigin.newColony:     return Icons.add_circle_outline;
      case HiveOrigin.split:         return Icons.call_split;
      case HiveOrigin.capturedSwarm: return Icons.catching_pokemon;
    }
  }

  String _originLabel(HiveOrigin o) {
    switch (o) {
      case HiveOrigin.newColony:     return 'New Colony';
      case HiveOrigin.split:         return 'Split From Existing Hive';
      case HiveOrigin.capturedSwarm: return 'Captured Swarm';
    }
  }

  Color _statusColor(HiveStatus s) {
    switch (s) {
      case HiveStatus.strong: return const Color(0xFF6E8B5E);
      case HiveStatus.medium: return const Color(0xFFD9952F);
      case HiveStatus.weak:   return const Color(0xFFB5564A);
    }
  }

  String _statusEmoji(HiveStatus s) {
    switch (s) {
      case HiveStatus.strong: return '🟢';
      case HiveStatus.medium: return '🟡';
      case HiveStatus.weak:   return '🔴';
    }
  }

  String _statusLabel(HiveStatus s) {
    switch (s) {
      case HiveStatus.strong: return 'Strong';
      case HiveStatus.medium: return 'Medium';
      case HiveStatus.weak:   return 'Weak';
    }
  }
}

// ── Reusable form section wrapper ────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.w700, color: Color(0xFF8C7257)),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
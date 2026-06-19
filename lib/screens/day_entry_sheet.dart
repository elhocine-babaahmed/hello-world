import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/hive_model.dart';
import '../providers/hives_provider.dart';
import '../providers/events_provider.dart';

class DayEntrySheet extends StatefulWidget {
  final DateTime date;
  final int? preselectedHiveId;
  const DayEntrySheet({super.key, required this.date, this.preselectedHiveId});

  @override
  State<DayEntrySheet> createState() => _DayEntrySheetState();
}

class _DayEntrySheetState extends State<DayEntrySheet> {

  // ── Required fields ──────────────────────────────────────────────────────
  int?       _hiveId;
  EventType  _type = EventType.inspection;

  // ── Inspection ───────────────────────────────────────────────────────────
  ColonyStrength? _colonyStrength;
  QueenStatus?    _queenStatus;
  BroodQuality?   _broodQuality;
  FoodStores?     _foodStores;

  // ── Feeding ──────────────────────────────────────────────────────────────
  double?  _feedingAmountL;
  bool     _customFeeding = false;
  final TextEditingController _customFeedingCtrl = TextEditingController();

  String?  _syrupRatio;
  bool     _customSyrup = false;
  final TextEditingController _customSyrupCtrl = TextEditingController();

  // ── Frames ───────────────────────────────────────────────────────────────
  int _framesAdded = 0;

  // ── General ──────────────────────────────────────────────────────────────
  final TextEditingController _notesCtrl = TextEditingController();
  DateTime? _nextActionDate;

  // ── Visibility helpers ───────────────────────────────────────────────────
  bool get _showInspection   => _type == EventType.inspection;
  bool get _showFeeding      => _type == EventType.feeding      || _type == EventType.inspection;
  bool get _showFrames       => _type == EventType.frameAdded   || _type == EventType.inspection;
  bool get _showQueenSection => _type == EventType.queenReplacement;

  @override
  void initState() {
    super.initState();
    _hiveId = widget.preselectedHiveId;
  }

  @override
  void dispose() {
    _customFeedingCtrl.dispose();
    _customSyrupCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  void _save() {
    if (_hiveId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a hive'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3A2A18),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Resolve feeding amount
    double? finalFeeding;
    if (_customFeeding) {
      finalFeeding = double.tryParse(_customFeedingCtrl.text.trim());
    } else {
      finalFeeding = _feedingAmountL;
    }

    // Resolve syrup ratio
    String? finalRatio;
    if (_customSyrup) {
      final raw = _customSyrupCtrl.text.trim();
      if (raw.isNotEmpty) finalRatio = raw;
    } else {
      finalRatio = _syrupRatio;
    }

    final event = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hiveId: _hiveId!,
      type: _type,
      date: widget.date,
      colonyStrength: _showInspection ? _colonyStrength : null,
      queenStatus:    (_showInspection || _showQueenSection) ? _queenStatus : null,
      broodQuality:   _showInspection ? _broodQuality : null,
      foodStores:     _showInspection ? _foodStores : null,
      feedingAmountL: _showFeeding ? finalFeeding : null,
      syrupRatio:     (_showFeeding && finalFeeding != null) ? finalRatio : null,
      framesAdded:    _showFrames && _framesAdded > 0 ? _framesAdded : null,
      notes:          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nextActionDate: _nextActionDate,
    );

    context.read<EventsProvider>().addEvent(event);
    Navigator.pop(context);
  }

  // ── Date picker ──────────────────────────────────────────────────────────
  Future<void> _pickNextActionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFD9952F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _nextActionDate = picked);
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hives = context.read<HivesProvider>().hives;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E2),
        title: Text(
          _formatDate(widget.date),
          style: const TextStyle(fontSize: 16, color: Color(0xFF8C7257), fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF3A2A18), fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [

          // ── Hive picker ─────────────────────────────────────────────────
          _Section(
            label: 'Hive *',
            child: hives.isEmpty
                ? const _NoHivesWarning()
                : _buildHivePicker(hives),
          ),

          const SizedBox(height: 20),

          // ── Event type ──────────────────────────────────────────────────
          _Section(
            label: 'Event Type *',
            child: _buildEventTypePicker(),
          ),

          // ── Inspection fields ────────────────────────────────────────────
          if (_showInspection) ...[
            const SizedBox(height: 20),
            _Section(
              label: 'Colony Strength',
              child: _buildOptions<ColonyStrength>(
                options: ColonyStrength.values,
                selected: _colonyStrength,
                label: (v) => v.label,
                onSelect: (v) => setState(() => _colonyStrength = v),
                scroll: true,
              ),
            ),
            const SizedBox(height: 20),
            _Section(
              label: 'Queen Status',
              child: _buildOptions<QueenStatus>(
                options: QueenStatus.values,
                selected: _queenStatus,
                label: (v) => v.label,
                onSelect: (v) => setState(() => _queenStatus = v),
                scroll: false,
              ),
            ),
            const SizedBox(height: 20),
            _Section(
              label: 'Brood Quality',
              child: _buildOptions<BroodQuality>(
                options: BroodQuality.values,
                selected: _broodQuality,
                label: (v) => v.label,
                onSelect: (v) => setState(() => _broodQuality = v),
                scroll: false,
              ),
            ),
            const SizedBox(height: 20),
            _Section(
              label: 'Food Stores',
              child: _buildOptions<FoodStores>(
                options: FoodStores.values,
                selected: _foodStores,
                label: (v) => v.label,
                onSelect: (v) => setState(() => _foodStores = v),
                scroll: false,
              ),
            ),
          ],

          // ── Queen replacement field ──────────────────────────────────────
          if (_showQueenSection) ...[
            const SizedBox(height: 20),
            _Section(
              label: 'Queen Status',
              child: _buildOptions<QueenStatus>(
                options: QueenStatus.values,
                selected: _queenStatus,
                label: (v) => v.label,
                onSelect: (v) => setState(() => _queenStatus = v),
                scroll: false,
              ),
            ),
          ],

          // ── Feeding fields ───────────────────────────────────────────────
          if (_showFeeding) ...[
            const SizedBox(height: 20),
            _Section(
              label: 'Feeding Amount (litres)',
              child: _buildFeedingAmountPicker(),
            ),
            if (_feedingAmountL != null || _customFeeding) ...[
              const SizedBox(height: 20),
              _Section(
                label: 'Syrup Ratio',
                child: _buildSyrupRatioPicker(),
              ),
            ],
          ],

          // ── Frames ──────────────────────────────────────────────────────
          if (_showFrames) ...[
            const SizedBox(height: 20),
            _Section(
              label: 'Frames Added',
              child: _buildFramesStepper(),
            ),
          ],

          // ── Notes (always) ───────────────────────────────────────────────
          const SizedBox(height: 20),
          _Section(
            label: 'Notes',
            child: TextField(
              controller: _notesCtrl,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A18)),
              decoration: InputDecoration(
                hintText: 'Observations, conditions, anything noteworthy…',
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

          // ── Next action (always) ─────────────────────────────────────────
          const SizedBox(height: 20),
          _Section(
            label: 'Next Action Date',
            child: _buildNextActionPicker(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Hive picker ───────────────────────────────────────────────────────────
  Widget _buildHivePicker(List<HiveModel> hives) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _hiveId != null ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _hiveId,
          hint: const Text('Select a hive', style: TextStyle(color: Color(0xFFB6A488), fontSize: 14)),
          isExpanded: true,
          dropdownColor: const Color(0xFFFFFDF8),
          icon: const Icon(Icons.expand_more, color: Color(0xFF8C7257)),
          items: hives.map((hive) {
            return DropdownMenuItem<int>(
              value: hive.id,
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: _statusColor(hive.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(hive.displayName, style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A18))),
                ],
              ),
            );
          }).toList(),
          onChanged: (id) => setState(() => _hiveId = id),
        ),
      ),
    );
  }

  Color _statusColor(HiveStatus s) {
    switch (s) {
      case HiveStatus.strong: return const Color(0xFF6E8B5E);
      case HiveStatus.medium: return const Color(0xFFD9952F);
      case HiveStatus.weak:   return const Color(0xFFB5564A);
    }
  }

  // ── Event type picker ─────────────────────────────────────────────────────
  Widget _buildEventTypePicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: EventType.values.map((type) {
          final isSelected = _type == type;
          return GestureDetector(
            onTap: () => setState(() {
              _type = type;
              // Reset type-specific fields when switching
              _framesAdded = 0;
              _feedingAmountL = null;
              _customFeeding = false;
              _customFeedingCtrl.clear();
              _syrupRatio = null;
              _customSyrup = false;
              _customSyrupCtrl.clear();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? type.color.withOpacity(0.12) : const Color(0xFFFFFDF8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? type.color : const Color(0xFFE8DCC2),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.icon, size: 14, color: isSelected ? type.color : const Color(0xFF8C7257)),
                  const SizedBox(width: 6),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? type.color : const Color(0xFF3A2A18),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Generic option selector ───────────────────────────────────────────────
  Widget _buildOptions<T>({
    required List<T> options,
    required T? selected,
    required String Function(T) label,
    required void Function(T) onSelect,
    required bool scroll,
  }) {
    final children = options.map((option) {
      final isSelected = option == selected;
      return GestureDetector(
        onTap: () => onSelect(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(right: scroll ? 8 : 0, bottom: scroll ? 0 : 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD9952F).withOpacity(0.12) : const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label(option),
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? const Color(0xFFD9952F) : const Color(0xFF3A2A18),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    }).toList();

    if (scroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: children),
      );
    }
    return Wrap(spacing: 8, runSpacing: 0, children: children);
  }

  // ── Feeding amount picker ─────────────────────────────────────────────────
  Widget _buildFeedingAmountPicker() {
    const presets = [0.5, 1.0, 1.5];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...presets.map((amount) {
              final isSelected = !_customFeeding && _feedingAmountL == amount;
              return GestureDetector(
                onTap: () => setState(() {
                  _feedingAmountL = amount;
                  _customFeeding = false;
                  _customFeedingCtrl.clear();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD9952F).withOpacity(0.12) : const Color(0xFFFFFDF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    '${amount}L',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                      color: isSelected ? const Color(0xFFD9952F) : const Color(0xFF3A2A18),
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => setState(() {
                _customFeeding = true;
                _feedingAmountL = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _customFeeding ? const Color(0xFFD9952F).withOpacity(0.12) : const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _customFeeding ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2),
                    width: _customFeeding ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _customFeeding ? FontWeight.w700 : FontWeight.normal,
                    color: _customFeeding ? const Color(0xFFD9952F) : const Color(0xFF3A2A18),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_customFeeding) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customFeedingCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A18)),
            decoration: InputDecoration(
              hintText: 'Enter amount in litres',
              hintStyle: const TextStyle(color: Color(0xFFB6A488)),
              suffixText: 'L',
              filled: true,
              fillColor: const Color(0xFFFFFDF8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8DCC2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8DCC2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD9952F), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  // ── Syrup ratio picker ────────────────────────────────────────────────────
  Widget _buildSyrupRatioPicker() {
    const ratios = ['1:1', '2:1'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...ratios.map((ratio) {
              final isSelected = !_customSyrup && _syrupRatio == ratio;
              return GestureDetector(
                onTap: () => setState(() {
                  _syrupRatio = ratio;
                  _customSyrup = false;
                  _customSyrupCtrl.clear();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD9952F).withOpacity(0.12) : const Color(0xFFFFFDF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    ratio,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                      color: isSelected ? const Color(0xFFD9952F) : const Color(0xFF3A2A18),
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => setState(() {
                _customSyrup = true;
                _syrupRatio = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _customSyrup ? const Color(0xFFD9952F).withOpacity(0.12) : const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _customSyrup ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2),
                    width: _customSyrup ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _customSyrup ? FontWeight.w700 : FontWeight.normal,
                    color: _customSyrup ? const Color(0xFFD9952F) : const Color(0xFF3A2A18),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_customSyrup) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customSyrupCtrl,
            style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A18)),
            decoration: InputDecoration(
              hintText: 'e.g. 3:2',
              hintStyle: const TextStyle(color: Color(0xFFB6A488)),
              filled: true,
              fillColor: const Color(0xFFFFFDF8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8DCC2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8DCC2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD9952F), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  // ── Frames stepper ────────────────────────────────────────────────────────
  Widget _buildFramesStepper() {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: _framesAdded > 0 ? () => setState(() => _framesAdded--) : null,
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            Text(
              '$_framesAdded',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF3A2A18)),
            ),
            const Text('frames', style: TextStyle(fontSize: 11, color: Color(0xFF8C7257))),
          ],
        ),
        const SizedBox(width: 16),
        _StepButton(
          icon: Icons.add,
          onTap: () => setState(() => _framesAdded++),
        ),
      ],
    );
  }

  // ── Next action picker ────────────────────────────────────────────────────
  Widget _buildNextActionPicker() {
    return GestureDetector(
      onTap: _pickNextActionDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _nextActionDate != null ? const Color(0xFFB5564A) : const Color(0xFFE8DCC2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_outlined,
              size: 18,
              color: _nextActionDate != null ? const Color(0xFFB5564A) : const Color(0xFF8C7257),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _nextActionDate != null
                    ? _formatDate(_nextActionDate!)
                    : 'Set a follow-up date (optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: _nextActionDate != null ? const Color(0xFF3A2A18) : const Color(0xFFB6A488),
                  fontWeight: _nextActionDate != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (_nextActionDate != null)
              GestureDetector(
                onTap: () => setState(() => _nextActionDate = null),
                child: const Icon(Icons.close, size: 16, color: Color(0xFFB6A488)),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

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

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFFDF8) : const Color(0xFFF5EDE0),
          shape: BoxShape.circle,
          border: Border.all(color: active ? const Color(0xFFE8DCC2) : const Color(0xFFF0E8D8)),
        ),
        child: Icon(icon, size: 20, color: active ? const Color(0xFF3A2A18) : const Color(0xFFD8C8AC)),
      ),
    );
  }
}

class _NoHivesWarning extends StatelessWidget {
  const _NoHivesWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD95A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_outlined, size: 18, color: Color(0xFFB8860B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No hives yet — add a hive first from the Hives tab.',
              style: TextStyle(fontSize: 13, color: Color(0xFF7A5800)),
            ),
          ),
        ],
      ),
    );
  }
}
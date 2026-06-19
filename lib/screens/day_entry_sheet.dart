import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/hive_model.dart';
import '../models/reminder_model.dart';
import '../providers/hives_provider.dart';
import '../providers/events_provider.dart';
import '../providers/reminders_provider.dart';

class DayEntrySheet extends StatefulWidget {
  final DateTime date;
  final int? preselectedHiveId;
  const DayEntrySheet({super.key, required this.date, this.preselectedHiveId});

  @override
  State<DayEntrySheet> createState() => _DayEntrySheetState();
}

class _DayEntrySheetState extends State<DayEntrySheet> {
  int? _hiveId;
  EventType _type = EventType.inspection;
  ColonyStrength? _colonyStrength;
  QueenStatus? _queenStatus;
  BroodQuality? _broodQuality;
  FoodStores? _foodStores;
  double? _feedingAmountL;
  bool _customFeeding = false;
  final TextEditingController _customFeedingCtrl = TextEditingController();
  String? _syrupRatio;
  bool _customSyrup = false;
  final TextEditingController _customSyrupCtrl = TextEditingController();
  int _framesAdded = 0;
  final TextEditingController _notesCtrl = TextEditingController();
  DateTime? _nextActionDate;

  bool get _showInspection => _type == EventType.inspection;
  bool get _showFeeding => _type == EventType.feeding || _type == EventType.inspection;
  bool get _showFrames => _type == EventType.frameAdded || _type == EventType.inspection;
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

    double? finalFeeding;
    if (_customFeeding) {
      finalFeeding = double.tryParse(_customFeedingCtrl.text.trim());
    } else {
      finalFeeding = _feedingAmountL;
    }

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
      queenStatus: (_showInspection || _showQueenSection) ? _queenStatus : null,
      broodQuality: _showInspection ? _broodQuality : null,
      foodStores: _showInspection ? _foodStores : null,
      feedingAmountL: _showFeeding ? finalFeeding : null,
      syrupRatio: (_showFeeding && finalFeeding != null) ? finalRatio : null,
      framesAdded: _showFrames && _framesAdded > 0 ? _framesAdded : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nextActionDate: _nextActionDate,
    );

    context.read<EventsProvider>().addEvent(event);

    if (_nextActionDate != null) {
      final reminder = ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hiveId: _hiveId!,
        title: 'Follow-up: ${_type.label}',
        dueDate: _nextActionDate!,
      );
      context.read<RemindersProvider>().addReminder(reminder);
    }

    Navigator.pop(context);
  }

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

  @override
  Widget build(BuildContext context) {
    final hives = context.read<HivesProvider>().hives;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E2),
        title: Text(_formatDate(widget.date), style: const TextStyle(fontSize: 16, color: Color(0xFF8C7257), fontWeight: FontWeight.normal)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [TextButton(onPressed: _save, child: const Text('Save', style: TextStyle(color: Color(0xFF3A2A18), fontWeight: FontWeight.w700, fontSize: 15)))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _Section(
            label: 'Hive *',
            child: hives.isEmpty
                ? const _NoHivesWarning()
                : Column(
                    children: hives.map((h) => GestureDetector(
                      onTap: () => setState(() => _hiveId = h.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: _hiveId == h.id ? const Color(0xFFD9952F).withOpacity(0.1) : const Color(0xFFFFFDF8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _hiveId == h.id ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.hive_outlined, size: 16, color: const Color(0xFF8C7257)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(h.displayName, style: const TextStyle(fontSize: 13, color: Color(0xFF3A2A18), fontWeight: FontWeight.w500))),
                            if (_hiveId == h.id) const Icon(Icons.check_circle, size: 18, color: Color(0xFFD9952F)),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
          ),
          const SizedBox(height: 20),
          _Section(
            label: 'Event Type *',
            child: Column(
              children: EventType.values.map((type) {
                final isSelected = _type == type;
                return GestureDetector(
                  onTap: () => setState(() => _type = type),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? type.color.withOpacity(0.1) : const Color(0xFFFFFDF8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? type.color : const Color(0xFFE8DCC2)),
                    ),
                    child: Row(
                      children: [
                        Icon(type.icon, size: 16, color: isSelected ? type.color : const Color(0xFF8C7257)),
                        const SizedBox(width: 10),
                        Text(type.label, style: TextStyle(fontSize: 13, color: isSelected ? type.color : const Color(0xFF3A2A18), fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                        const Spacer(),
                        if (isSelected) Icon(Icons.check_circle, size: 18, color: type.color),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_showInspection) ...[const SizedBox(height: 20), _Section(label: 'Colony Strength', child: _buildOptions<ColonyStrength>(ColonyStrength.values, _colonyStrength, (v) => v.label, (v) => setState(() => _colonyStrength = v)))],
          if (_showInspection) ...[const SizedBox(height: 20), _Section(label: 'Queen Status', child: _buildOptions<QueenStatus>(QueenStatus.values, _queenStatus, (v) => v.label, (v) => setState(() => _queenStatus = v)))],
          if (_showInspection) ...[const SizedBox(height: 20), _Section(label: 'Brood Quality', child: _buildOptions<BroodQuality>(BroodQuality.values, _broodQuality, (v) => v.label, (v) => setState(() => _broodQuality = v)))],
          if (_showInspection) ...[const SizedBox(height: 20), _Section(label: 'Food Stores', child: _buildOptions<FoodStores>(FoodStores.values, _foodStores, (v) => v.label, (v) => setState(() => _foodStores = v)))],
          if (_showFeeding) ...[const SizedBox(height: 20), _Section(label: 'Feeding Amount', child: _buildFeedingPicker())],
          if (_showFeeding && _feedingAmountL != null) ...[const SizedBox(height: 20), _Section(label: 'Syrup Ratio', child: _buildSyrupPicker())],
          if (_showFrames) ...[const SizedBox(height: 20), _Section(label: 'Frames Added', child: _buildFramesStepper())],
          const SizedBox(height: 20),
          _Section(label: 'Notes (optional)', child: TextField(controller: _notesCtrl, maxLines: 3, decoration: InputDecoration(hintText: 'Add observations...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))))),
          const SizedBox(height: 20),
          _Section(
            label: 'Next Action Date (optional)',
            child: GestureDetector(
              onTap: _pickNextActionDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8DCC2))),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: const Color(0xFF8C7257)),
                    const SizedBox(width: 10),
                    Text(_nextActionDate == null ? 'Tap to set reminder date' : _formatDateFull(_nextActionDate!), style: TextStyle(fontSize: 13, color: _nextActionDate == null ? const Color(0xFFB6A488) : const Color(0xFF3A2A18))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions<T>(List<T> options, T? selected, String Function(T) label, Function(T) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: isSelected ? const Color(0xFFD9952F).withOpacity(0.1) : const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(8), border: Border.all(color: isSelected ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2))),
            child: Text(label(opt), style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFFD9952F) : const Color(0xFF8C7257), fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedingPicker() {
    return Column(
      children: [
        Row(
          children: [0.5, 1.0, 1.5].map((amt) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() { _feedingAmountL = amt; _customFeeding = false; }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: _feedingAmountL == amt && !_customFeeding ? const Color(0xFFD9952F).withOpacity(0.1) : const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(8), border: Border.all(color: _feedingAmountL == amt && !_customFeeding ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2))),
                child: Text('${amt}L', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: _feedingAmountL == amt && !_customFeeding ? FontWeight.w600 : FontWeight.normal, color: _feedingAmountL == amt && !_customFeeding ? const Color(0xFFD9952F) : const Color(0xFF8C7257))),
              ),
            ),
          )).toList()..insert(0, const SizedBox(width: 8)).removeAt(4),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _customFeeding = !_customFeeding),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: _customFeeding ? const Color(0xFFD9952F).withOpacity(0.1) : const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(8), border: Border.all(color: _customFeeding ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2))),
            child: Row(
              children: [Icon(Icons.edit_outlined, size: 14, color: _customFeeding ? const Color(0xFFD9952F) : const Color(0xFF8C7257)), const SizedBox(width: 6), Text('Custom amount', style: TextStyle(fontSize: 12, color: _customFeeding ? const Color(0xFFD9952F) : const Color(0xFF8C7257)))],
            ),
          ),
        ),
        if (_customFeeding) ...[const SizedBox(height: 10), TextField(controller: _customFeedingCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(hintText: 'Enter liters', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))],
      ],
    );
  }

  Widget _buildSyrupPicker() {
    return Column(
      children: [
        Row(
          children: ['1:1', '2:1'].map((ratio) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() { _syrupRatio = ratio; _customSyrup = false; }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: _syrupRatio == ratio && !_customSyrup ? const Color(0xFFD9952F).withOpacity(0.1) : const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(8), border: Border.all(color: _syrupRatio == ratio && !_customSyrup ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2))),
                child: Text(ratio, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: _syrupRatio == ratio && !_customSyrup ? FontWeight.w600 : FontWeight.normal, color: _syrupRatio == ratio && !_customSyrup ? const Color(0xFFD9952F) : const Color(0xFF8C7257))),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _customSyrup = !_customSyrup),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: _customSyrup ? const Color(0xFFD9952F).withOpacity(0.1) : const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(8), border: Border.all(color: _customSyrup ? const Color(0xFFD9952F) : const Color(0xFFE8DCC2))),
            child: Row(
              children: [Icon(Icons.edit_outlined, size: 14, color: _customSyrup ? const Color(0xFFD9952F) : const Color(0xFF8C7257)), const SizedBox(width: 6), Text('Custom ratio', style: TextStyle(fontSize: 12, color: _customSyrup ? const Color(0xFFD9952F) : const Color(0xFF8C7257)))],
            ),
          ),
        ),
        if (_customSyrup) ...[const SizedBox(height: 10), TextField(controller: _customSyrupCtrl, decoration: InputDecoration(hintText: 'e.g., 3:1', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))],
      ],
    );
  }

  Widget _buildFramesStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8DCC2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _framesAdded > 0 ? () => setState(() => _framesAdded--) : null),
          Text('$_framesAdded', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF3A2A18))),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _framesAdded++)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dow = days[d.weekday - 1];
    return '$dow ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatDateFull(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.w700, color: Color(0xFF8C7257))),
      const SizedBox(height: 8),
      child,
    ]);
  }
}

class _NoHivesWarning extends StatelessWidget {
  const _NoHivesWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFFBF3E2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8DCC2))),
      child: Column(
        children: [
          Icon(Icons.hive_outlined, size: 28, color: const Color(0xFFB6A488)),
          const SizedBox(height: 8),
          const Text('No hives yet — create one first', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFFB6A488))),
        ],
      ),
    );
  }
}

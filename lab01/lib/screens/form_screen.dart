import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_category.dart';
import '../models/game_night.dart';
import '../utils/format.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.item});

  final GameNight? item;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final GameNight _initial = widget.item ?? GameNight.empty();
  late final bool _isNew = widget.item == null;
  late final DateTime _opened = DateTime(
    _initial.startsAt.year,
    _initial.startsAt.month,
    _initial.startsAt.day,
    _initial.startsAt.hour,
    _initial.startsAt.minute,
  );

  late final TextEditingController _title = TextEditingController(
    text: _initial.title,
  );
  late final TextEditingController _place = TextEditingController(
    text: _initial.place,
  );
  late final TextEditingController _seats = TextEditingController(
    text: _initial.seats.toString(),
  );
  late final TextEditingController _rules = TextEditingController(
    text: _initial.rules ?? '',
  );
  late final TextEditingController _dateText = TextEditingController(
    text: formatDate(_opened),
  );
  late final TextEditingController _timeText = TextEditingController(
    text: formatTime(_opened.hour, _opened.minute),
  );

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _placeFocus = FocusNode();
  final FocusNode _seatsFocus = FocusNode();
  final FocusNode _rulesFocus = FocusNode();

  late DateTime _date = DateTime(_opened.year, _opened.month, _opened.day);
  late TimeOfDay _time = TimeOfDay(hour: _opened.hour, minute: _opened.minute);
  late GameCategory? _category = _initial.category;
  late bool _online = _initial.online;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _seats.dispose();
    _rules.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _seatsFocus.dispose();
    _rulesFocus.dispose();
    super.dispose();
  }

  DateTime _combined() =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  bool get _dirty =>
      _title.text != _initial.title ||
      _place.text != _initial.place ||
      _seats.text != _initial.seats.toString() ||
      _rules.text != (_initial.rules ?? '') ||
      _category != _initial.category ||
      _online != _initial.online ||
      _combined() != _opened;

  void _dismissKeyboard(PointerDownEvent event) =>
      FocusManager.instance.primaryFocus?.unfocus();

  String? _validateTitle(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 3 || text.length > 60) {
      return 'Title must be 3–60 characters';
    }
    return null;
  }

  String? _validateCategory(GameCategory? value) =>
      value == null ? 'Pick a category' : null;

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Pick a date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isNew && _date.isBefore(today)) return 'Pick today or a later date';
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.isEmpty) return 'Pick a time';
    if (_isNew && !_combined().isAfter(DateTime.now())) {
      return 'Pick a time in the future';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return _online ? 'Link is required' : 'Place is required';
    if (_online && !text.contains('://')) return 'Link must contain ://';
    return null;
  }

  String? _validateSeats(String? value) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null || n < 1 || n > 500) {
      return 'Enter a whole number from 1 to 500';
    }
    if (!_isNew && n < _initial.count) {
      return 'Not below the ${_initial.count} already joined';
    }
    return null;
  }

  String? _validateRules(String? value) =>
      (value ?? '').length > 200 ? 'Up to 200 characters' : null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = _isNew || !_date.isBefore(today) ? today : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: first,
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return;
    _dateText.text = formatDate(picked);
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null || !mounted) return;
    _timeText.text = formatTime(picked.hour, picked.minute);
    setState(() => _time = picked);
  }

  GameNight _result() {
    final rules = _rules.text.trim();
    return _initial.copyWith(
      title: _title.text.trim(),
      category: _category,
      startsAt: _combined(),
      place: _place.text.trim(),
      seats: int.tryParse(_seats.text.trim()) ?? _initial.seats,
      online: _online,
      rules: rules.isEmpty ? null : rules,
      clearRules: rules.isEmpty,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context, _result());
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop || _saving) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'New game night' : 'Edit game night'),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  validator: _validateTitle,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<GameCategory>(
                  initialValue: _category,
                  isExpanded: true,
                  validator: _validateCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in GameCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon),
                            const SizedBox(width: 12),
                            Text(c.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateText,
                        readOnly: true,
                        validator: _validateDate,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _timeText,
                        readOnly: true,
                        validator: _validateTime,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.schedule),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _online,
                  title: const Text('Online'),
                  subtitle: const Text('The place becomes a link'),
                  onChanged: (value) =>
                      setState(() => _online = value ?? false),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  textInputAction: TextInputAction.next,
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  validator: _validatePlace,
                  decoration: InputDecoration(
                    labelText: _online ? 'Link' : 'Place',
                    border: const OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _seatsFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _seats,
                  focusNode: _seatsFocus,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateSeats,
                  decoration: const InputDecoration(
                    labelText: 'Seats',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _rulesFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rules,
                  focusNode: _rulesFocus,
                  maxLength: 200,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  validator: _validateRules,
                  decoration: const InputDecoration(
                    labelText: 'Rules (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

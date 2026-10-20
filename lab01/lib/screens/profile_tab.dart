import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.items,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
    this.drawer,
  });

  final Profile profile;
  final List<GameNight> items;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Widget? drawer;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final RegExp _groupPattern = RegExp(r'^[A-Za-z0-9-]{2,10}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _group = TextEditingController(
    text: widget.profile.group,
  );

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final p = widget.profile;
    if (_name.text != p.name) _name.text = p.name;
    if (_group.text != p.group) _group.text = p.group;
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return _groupPattern.hasMatch(text)
        ? null
        : 'Use letters, digits and "-", 2–10 characters';
  }

  void _save() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    widget.onProfileChanged(
      widget.profile.copyWith(
        name: _name.text.trim(),
        group: _group.text.trim(),
      ),
    );
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final name = widget.profile.name;
    final lists = name.isEmpty
        ? 0
        : widget.items.where((i) => i.contains(name)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: widget.drawer,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _save(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _group,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateGroup,
                  decoration: const InputDecoration(
                    labelText: 'Group',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _save(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: Text('You are on $lists ${lists == 1 ? 'list' : 'lists'}'),
          ),
          const SizedBox(height: 16),
          Text('Theme', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final mode in ThemeMode.values)
                ChoiceChip(
                  label: Text(_modeLabel(mode)),
                  selected: widget.themeMode == mode,
                  onSelected: (_) => widget.onThemeModeChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

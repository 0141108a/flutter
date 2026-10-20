import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/game_night.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late GameNight _item = widget.args.item;
  late final Timer _timer;

  String get _me => widget.args.userName.trim();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<bool?> _confirm(String title, String message, String action) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _openProfile() {
    widget.args.onOpenProfile();
    Navigator.pop(context);
  }

  Future<void> _join() async {
    final name = _me;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final confirmed = await _confirm(
      'Join this game night?',
      _item.title,
      'Join',
    );
    if (confirmed != true || !mounted) return;
    final updated = _item.copyWith(players: [..._item.players, name]);
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  void _leave() {
    final name = _me;
    final updated = _item.copyWith(
      players: [
        for (final p in _item.players)
          if (p != name) p,
      ],
    );
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<GameNight>(
      context,
      Routes.form,
      arguments: FormArgs(item: _item),
    );
    if (edited == null || !mounted) return;
    setState(() => _item = edited);
    widget.args.onChanged(edited);
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(
      'Delete this game night?',
      _item.title,
      'Delete',
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_item);
    Navigator.pop(context);
  }

  Future<void> _onMenu(_MenuAction action) => switch (action) {
    _MenuAction.edit => _edit(),
    _MenuAction.delete => _delete(),
  };

  String _countdownText(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'In ${formatDuration(left)}',
    Started(:final since) => 'Started ${formatDuration(since)} ago',
    Ended() => 'Ended',
  };

  Widget _header(ColorScheme scheme) {
    final color = _item.category.color(scheme);

    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/header.jpg', fit: BoxFit.cover),
          ColoredBox(color: scheme.scrim.withValues(alpha: 0.4)),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              child: Icon(_item.category.icon, size: 36, color: color),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Chip(
              avatar: Icon(_item.category.icon, size: 18),
              label: Text(_item.category.label),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Chip(label: Text(_countdownText(_item.countdown))),
          ),
        ],
      ),
    );
  }

  Widget _aboutTab() {
    final (:taken, :free) = _item.places;
    final rules = _item.rules;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(formatDateTime(_item.startsAt)),
          subtitle: const Text('Date and time'),
        ),
        ListTile(
          leading: Icon(_item.online ? Icons.link : Icons.place_outlined),
          title: Text(_item.place),
          subtitle: Text(_item.online ? 'Online' : 'Venue'),
        ),
        ListTile(
          leading: const Icon(Icons.event_seat_outlined),
          title: Text('Places: $taken of ${_item.seats}'),
          subtitle: Text('$free free'),
        ),
        if (rules != null)
          ListTile(
            leading: const Icon(Icons.rule),
            title: Text(rules),
            subtitle: const Text('Rules'),
          ),
      ],
    );
  }

  Widget _namesTab(ThemeData theme) {
    final players = _item.players;
    if (players.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody has joined yet',
      );
    }

    final scheme = theme.colorScheme;

    return ListView(
      children: [
        for (final name in players)
          ListTile(
            leading: const Icon(Icons.person_outline),
            tileColor: name == _me ? scheme.primaryContainer : null,
            title: Text(
              name == _me ? '$name (You)' : name,
              style: name == _me
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String label;
    final VoidCallback? action;
    if (_item.contains(_me)) {
      label = 'Leave';
      action = _leave;
    } else if (_item.isFull) {
      label = 'Full';
      action = null;
    } else {
      label = 'Join';
      action = _join;
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game night'),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (_) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _header(theme.colorScheme),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_item.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [_aboutTab(), _namesTab(theme)]),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: action, child: Text(label)),
            ),
          ),
        ),
      ),
    );
  }
}

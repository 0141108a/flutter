import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/game_night.dart';
import '../models/profile.dart';
import '../widgets/app_drawer.dart';
import '../routes.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<GameNight> _items = buildSeed();
  Profile _profile = const Profile.empty();
  int _index = 0;

  void _goToTab(int index) => setState(() => _index = index);

  void _toggleFavourite(GameNight item) {
    setState(() {
      _items = [
        for (final i in _items)
          i.id == item.id ? i.copyWith(favourite: !i.favourite) : i,
      ];
    });
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  void _replace(GameNight updated) {
    setState(() {
      _items = [for (final i in _items) i.id == updated.id ? updated : i];
    });
  }

  void _delete(GameNight item) {
    setState(() {
      _items = [
        for (final i in _items)
          if (i.id != item.id) i,
      ];
    });
  }

  void _open(GameNight item) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        item: item,
        userName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onOpenProfile: () => _goToTab(2),
      ),
    );
  }

  Future<void> _add() async {
    final created = await Navigator.pushNamed<GameNight>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _items = [..._items, created]);
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Game Nights: a board game club app.\nAll data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'The seed game nights come back and the profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final seed = buildSeed();
    setState(() {
      _items = seed;
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawer = AppDrawer(onAbout: _showAbout, onReset: _confirmReset);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ListTab(
            items: _items,
            drawer: drawer,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
            onAdd: _add,
          ),
          FavouritesTab(
            items: _items,
            drawer: drawer,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _goToTab(0),
          ),
          ProfileTab(
            profile: _profile,
            items: _items,
            drawer: drawer,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Nights',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

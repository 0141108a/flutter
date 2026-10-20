import 'package:flutter/material.dart';

import '../models/game_category.dart';
import '../models/game_night.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_night_card.dart';

class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onAdd,
    this.drawer,
  });

  final List<GameNight> items;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<GameNight> onToggleFavourite;
  final VoidCallback onAdd;
  final Widget? drawer;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  GameCategory? _category;
  bool _showPast = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<GameNight> get _visible {
    final q = _query.trim().toLowerCase();
    final found = widget.items.where(
      (i) =>
          (q.isEmpty || i.title.toLowerCase().contains(q)) &&
          (_category == null || i.category == _category) &&
          (_showPast || !i.isPast),
    );
    return [...found]..sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.startsAt.compareTo(b.startsAt);
    });
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final shown = _visible;

    return Scaffold(
      appBar: AppBar(title: const Text('Game nights')),
      drawer: widget.drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAdd,
        tooltip: 'New game night',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search game nights',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear',
                        onPressed: _clearSearch,
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final c in GameCategory.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                ],
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('Past items'),
                  selected: _showPast,
                  onSelected: (value) => setState(() => _showPast = value),
                ),
              ],
            ),
          ),
          Expanded(child: _buildResults(shown)),
        ],
      ),
    );
  }

  Widget _buildResults(List<GameNight> shown) {
    if (shown.isEmpty) {
      final canClear = _query.isNotEmpty;
      return EmptyState(
        icon: Icons.search_off,
        message: 'No game nights match',
        buttonLabel: canClear ? 'Clear search' : null,
        onPressed: canClear ? _clearSearch : null,
      );
    }

    Widget cardFor(GameNight item) => GameNightCard(
      item: item,
      onTap: () => widget.onOpen(item),
      onToggleFavourite: () => widget.onToggleFavourite(item),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = EdgeInsets.fromLTRB(16, 8, 16, 88);
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: padding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 120,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: shown.length,
            itemBuilder: (_, i) => cardFor(shown[i]),
          );
        }
        return ListView.separated(
          padding: padding,
          itemCount: shown.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => cardFor(shown[i]),
        );
      },
    );
  }
}

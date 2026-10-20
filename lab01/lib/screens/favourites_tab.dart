import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_night_card.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
    this.drawer,
  });

  final List<GameNight> items;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<GameNight> onToggleFavourite;
  final VoidCallback onBrowse;
  final Widget? drawer;

  List<GameNight> get _favourites => [
    for (final i in items)
      if (i.favourite) i,
  ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  @override
  Widget build(BuildContext context) {
    final favourites = _favourites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      drawer: drawer,
      body: favourites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              message: 'No favourites yet',
              buttonLabel: 'Browse game nights',
              onPressed: onBrowse,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favourites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = favourites[i];
                return GameNightCard(
                  item: item,
                  onTap: () => onOpen(item),
                  onToggleFavourite: () => onToggleFavourite(item),
                );
              },
            ),
    );
  }
}

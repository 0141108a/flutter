import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../utils/format.dart';

class GameNightCard extends StatelessWidget {
  const GameNightCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final GameNight item;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = item.category.color(scheme);

    final (:taken, :free) = item.places;

    final badge = item.isFull ? 'FULL' : (free <= 5 ? '$free left' : null);
    final badgeBackground = item.isFull
        ? scheme.errorContainer
        : scheme.tertiaryContainer;
    final badgeForeground = item.isFull
        ? scheme.onErrorContainer
        : scheme.onTertiaryContainer;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(item.category.icon, color: color),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: badgeBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: badgeForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateTime(item.startsAt)} · $taken/${item.seats}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          item.online ? Icons.link : Icons.place_outlined,
                          size: 16,
                          color: scheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                isSelected: item.favourite,
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                color: scheme.outline,
                tooltip: item.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

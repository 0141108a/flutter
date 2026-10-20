import 'package:flutter/material.dart';

enum GameCategory {
  strategy('Strategy', Icons.psychology),
  party('Party', Icons.celebration),
  cooperative('Co-op', Icons.groups),
  cards('Cards', Icons.style),
  rpg('RPG', Icons.auto_stories),
  war('War games', Icons.shield);

  const GameCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    GameCategory.strategy => scheme.primary,
    GameCategory.party => scheme.tertiary,
    GameCategory.cooperative => scheme.secondary,
    GameCategory.cards => scheme.error,
    GameCategory.rpg => scheme.outline,
    GameCategory.war => scheme.surfaceTint,
  };
}

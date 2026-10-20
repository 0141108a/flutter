import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final seed = ThemeData().colorScheme.primary;
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
  );
}

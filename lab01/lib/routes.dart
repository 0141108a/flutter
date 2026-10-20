import 'package:flutter/material.dart';

import 'models/game_night.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

class Routes {
  const Routes._();

  static const String shell = '/';
  static const String detail = '/detail';
  static const String form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.item,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final GameNight item;
  final String userName;
  final ValueChanged<GameNight> onChanged;
  final ValueChanged<GameNight> onDelete;
  final VoidCallback onOpenProfile;
}

class FormArgs {
  const FormArgs({this.item});

  final GameNight? item;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments;
      if (args is! DetailArgs) return null;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      );
    case Routes.form:
      final args = settings.arguments;
      if (args is! FormArgs) return null;
      return MaterialPageRoute<GameNight>(
        settings: settings,
        builder: (_) => FormScreen(item: args.item),
      );
    default:
      return null;
  }
}

Route<void> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}

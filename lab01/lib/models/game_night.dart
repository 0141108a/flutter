import 'countdown.dart';
import 'game_category.dart';

class GameNight {
  const GameNight({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.place,
    required this.seats,
    required this._players,
    required this.online,
    this.rules,
    this.favourite = false,
  });

  GameNight.empty()
    : this(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        category: GameCategory.strategy,
        startsAt: DateTime.now().add(const Duration(days: 1)),
        place: '',
        seats: 6,
        players: const [],
        online: false,
      );

  static const Duration length = Duration(hours: 3);

  final String id;
  final String title;
  final GameCategory category;
  final DateTime startsAt;
  final String place;
  final int seats;
  final bool online;
  final String? rules;
  final bool favourite;

  final List<String> _players;

  List<String> get players => List.unmodifiable(_players);

  int get count => _players.length;
  int get free => seats - count;
  bool get isFull => count >= seats;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => _players.contains(name);

  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown get countdown {
    final diff = startsAt.difference(DateTime.now());
    if (diff > Duration.zero) return Upcoming(diff);
    final since = -diff;
    return since < length ? Started(since) : const Ended();
  }

  GameNight copyWith({
    String? id,
    String? title,
    GameCategory? category,
    DateTime? startsAt,
    String? place,
    int? seats,
    List<String>? players,
    bool? online,
    String? rules,
    bool clearRules = false,
    bool? favourite,
  }) => GameNight(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    place: place ?? this.place,
    seats: seats ?? this.seats,
    players: players ?? _players,
    online: online ?? this.online,
    rules: clearRules ? null : (rules ?? this.rules),
    favourite: favourite ?? this.favourite,
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}users.json');
  }

  Future<void> save(List<User> users) async {
    final file = await _file();
    await file.writeAsString(jsonEncode([for (final u in users) u.toJson()]));
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final data = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [for (final e in data) User.fromJson(e as Map<String, dynamic>)];
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final http.Response r = await _api.get(Uri.https(_api.host, '/users'));
    final body = _api.decode(r);
    try {
      return (body as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BadResponseException('users: $e');
    }
  }

  Future<User> getById(int id) async {
    final http.Response r = await _api.get(Uri.https(_api.host, '/users/$id'));
    final body = _api.decode(r);
    try {
      return User.fromJson(body as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final http.Response r = await _api.post(
      Uri.https(_api.host, '/users'),
      draft.toJson(),
    );
    if (r.statusCode != 201) {
      throw BadResponseException('users: expected 201, got ${r.statusCode}');
    }
    final body = _api.decode(r);
    try {
      return User.fromJson(body as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users: $e');
    }
  }
}

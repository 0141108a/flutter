import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user_list.dart';
import 'users_model.dart';
import 'views.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();

    final Widget body;
    if (m.loading && m.items.isEmpty) {
      body = const LoadingView();
    } else {
      body = switch (m.error) {
        null => RefreshIndicator(onRefresh: m.load, child: UserList(m.items)),
        NoConnectionException() => Offline(onRetry: m.load),
        NotFoundException() || UnauthorizedException() => const GenericError(),
        ServerException(:final status) => ServerError(status, onRetry: m.load),
        BadResponseException() => const GenericError(),
      };
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

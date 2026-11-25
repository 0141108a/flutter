import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user_list.dart';
import 'users_model.dart';
import 'views.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.select<SettingsModel, String?>((s) => s.city);
    final shown = city == null
        ? m.items
        : [
            for (final u in m.items)
              if (u.address.city == city) u,
          ];

    final Widget body;
    if (m.loading && m.items.isEmpty) {
      body = const LoadingView();
    } else {
      body = switch (m.error) {
        null => Column(
          children: [
            if (m.fromCache)
              MaterialBanner(
                leading: const Icon(Icons.cloud_off),
                content: const Text('Saved data · no connection'),
                actions: [
                  TextButton(onPressed: m.load, child: const Text('Retry')),
                ],
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: m.load,
                child: UserList(shown),
              ),
            ),
          ],
        ),
        NoConnectionException() => Offline(onRetry: m.load),
        NotFoundException() || UnauthorizedException() => const GenericError(),
        ServerException(:final status) => ServerError(status, onRetry: m.load),
        BadResponseException() => const GenericError(),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
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

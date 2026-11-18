import 'package:flutter/material.dart';

import 'user.dart';
import 'user_detail_screen.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final u = users[index];
        return ListTile(
          title: Text(u.name),
          subtitle: Text('${u.email}\n${u.address.city}'),
          isThreeLine: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => UserDetailScreen(u)),
            );
          },
        );
      },
    );
  }
}

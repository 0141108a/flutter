import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _Field('Username', user.username),
          _Field('Email', user.email),
          _Field('Phone', user.phone, onTap: () {}),
          _Field('Website', user.website ?? '—', onTap: () {}),
          _Field('Address', '${a.street}, ${a.suite}\n${a.city}, ${a.zipcode}'),
          _Field('Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _Field(
            'Company',
            '${user.company.name}\n${user.company.catchPhrase}',
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value, {this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), subtitle: Text(value), onTap: onTap);
  }
}

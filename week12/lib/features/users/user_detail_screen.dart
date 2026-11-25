import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
import 'user.dart';

Future<void> _open(BuildContext context, Uri uri) async {
  bool ok;
  try {
    ok = await launchUrl(uri);
  } on PlatformException {
    ok = false;
  }
  if (!context.mounted) return;
  if (!ok) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No app can open this')));
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final site = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _Field('Username', user.username),
          _Field(
            'Email',
            user.email,
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          _Field(
            'Phone',
            user.phone,
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          _Field(
            'Website',
            site ?? '—',
            onTap: site == null
                ? null
                : () => _open(context, Uri.parse('https://$site')),
          ),
          _Field('Address', '${a.street}, ${a.suite}\n${a.city}, ${a.zipcode}'),
          _Field('Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _Field(
            'Company',
            '${user.company.name}\n${user.company.catchPhrase}',
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final token = context.read<AuthModel>().token;
                  if (token == null) return;
                  await Clipboard.setData(ClipboardData(text: token));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token copied (debug only)')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy token to clipboard'),
              ),
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

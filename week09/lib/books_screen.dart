import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
          ),
        ),
        actions: const [CartBadge(), SizedBox(width: 8)],
      ),
      body: ListView(children: [for (final b in shown) _BookRow(b)]),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow(this.book);

  final Book book;

  @override
  Widget build(BuildContext context) {
    final added = context.select<Cart, bool>((c) => c.qtyOf(book) > 0);
    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(book);
                if (ok) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Added'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}

# NOTES

## Level 1: Lift it up

Adding the total price to the badge (a second parameter `total` passed from the owner all the way down) touched 2 constructors (BooksScreen and CartBadge) in 3 files (main.dart, books_screen.dart, cart_badge.dart).

One tap on Add printed 7 lines in the console (1 x "BooksScreen build" + 6 x "row ..."). setState in Shell marked the whole screen and every row dirty.

## Level 3: provider errors

Loud error (context.watch inside onPressed):
Tried to listen to a value exposed with provider, from outside of the widget tree.

Silent error (context.read<Cart>().count inside build): no error, it compiles and runs, but the badge stays at 0 forever because nobody subscribed to the cart.

## Level 4: badge rebuilds

3 presses on + with context.watch in the badge: "badge build" printed 3 times.
3 presses on + with context.select on count: "badge build" printed 0 times (it printed once when a book was removed).

## Where does it live?

- The cart: provided. Books screen, Cart screen and the badge all need it, so it sits above MaterialApp and each widget subscribes where it shows the value.
- The search text in the Books AppBar: ephemeral. Only the Books screen uses it, so it lives in that screen's State.
- Whether the total on the Cart screen is expanded or collapsed: ephemeral. It is a local detail of one widget and dies with it.
- The theme mode (dark-mode switch): provided. MaterialApp reads it and a switch somewhere else changes it, so it must live above MaterialApp.
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:shh/dialog.dart';
import 'package:shh/navbar.dart';

import 'add_memory/add_memory.dart';
import 'add_person/add_person.dart';

class NavbarWrapper extends HookWidget {
  final Widget? child;

  const NavbarWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    log('Navbar in child: $child');

    final selectedIndex = useState<int>(0);

    final selectedValue = selectedIndex.value;
    const primary = Colors.white;
    const black = Colors.black;
    final is0 = selectedValue == 0;
    final is1 = selectedValue == 1;
    final is2 = selectedValue == 2;
    final is3 = selectedValue == 3;

    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            50.0,
          ),
        ),
        child: const Icon(Icons.add),
        onPressed: () {
          showMultiActionDialog(
            "What would you like to do?",
            "Choose one option.",
            [() => showAddPerson(), () => showAddMemory()],
            ["Add Person", "Add Memory"],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.primary,
        height: 90,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                context.go("/");
                selectedIndex.value = 0;
              },
              iconSize: 30,
              icon: const Icon(Icons.home),
              color: is0 ? primary : black,
            ),
            IconButton(
              onPressed: () {
                context.go("/random-memory");
                selectedIndex.value = 2;
              },
              iconSize: 30,
              icon: const Icon(Icons.refresh),
              color: is2 ? primary : black,
            ),
            IconButton(
              onPressed: () {
                // context.go("/random-memory");
                // selectedIndex.value = 2;
              },
              iconSize: 30,
              icon: const Icon(Icons.person),
              color: is2 ? primary : black,
            ),
            IconButton(
              onPressed: () {
                context.go("/settings");
                selectedIndex.value = 3;
              },
              iconSize: 30,
              icon: const Icon(Icons.settings),
              color: is3 ? primary : black,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Navbar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Settings extends HookWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: const Text("Settings"),
    );
  }
}

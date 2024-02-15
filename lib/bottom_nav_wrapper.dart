import 'dart:developer';

import 'package:flutter/material.dart';

import 'bottom_nav.dart';

class BottomNavWrapper extends StatelessWidget {
  final Widget? child;

  const BottomNavWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    log('Navbar in child: $child');

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }
}

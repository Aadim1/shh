import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'expandable_fab/action_button.dart';
import 'expandable_fab/expandable_fab.dart';

class BottomNavItem extends ConsumerWidget {
  final String route;
  final String name;
  final IconData icon;
  final ValueNotifier currentRoute;
  final Color iconColor;

  const BottomNavItem({
    super.key,
    required this.route,
    required this.icon,
    required this.name,
    required this.currentRoute,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool current = currentRoute.value == route;
    return GestureDetector(
      onTap: () {
        currentRoute.value = route;
        context.go(route);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: current
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Icon(
              icon,
              color: current
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black,
              size: 17,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: current
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BottomNavigation extends HookWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute_ =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final currentRoute = useState<String>(currentRoute_);

    return const SizedBox.shrink();

    Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        // height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0.0),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomNavItem(
              route: '/',
              icon: Icons.home,
              name: 'Home',
              currentRoute: currentRoute,
              iconColor: Colors.black,
            ),
            const SizedBox(
              width: 5,
            ),
            BottomNavItem(
              route: '/favorites',
              icon: Icons.favorite,
              name: 'Favorite',
              currentRoute: currentRoute,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: 60,
              height: 100,
              child: ExpandableFab(
                distance: 60,
                children: [
                  ActionButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => log('Add Peron'),
                  ),
                  ActionButton(
                    icon: const Icon(Icons.memory),
                    onPressed: () => log('Add Memory'),
                  )
                ],
              ),
            ),
            BottomNavItem(
              route: '/random-memory',
              icon: Icons.refresh,
              name: 'Random',
              currentRoute: currentRoute,
              iconColor: Colors.black,
            ),
            const SizedBox(
              width: 5,
            ),
            BottomNavItem(
              route: '/settings',
              icon: Icons.settings,
              name: 'Settings',
              currentRoute: currentRoute,
              iconColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

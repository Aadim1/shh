import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shh/favorite/favorite.dart';
import 'package:shh/home/home.dart';
import 'package:shh/image_picker.dart';
import 'package:shh/random/random.dart';
import 'package:shh/settings/settings.dart';

import 'memory/memory.dart';
import 'navbar_wrapper.dart';

class NavigatorKeyHolder {
  // Private constructor
  NavigatorKeyHolder._privateConstructor();

  // Static private instance of the class
  static final NavigatorKeyHolder _instance =
      NavigatorKeyHolder._privateConstructor();

  // Factory constructor to return the same instance
  factory NavigatorKeyHolder() {
    return _instance;
  }

  // The GlobalKey<NavigatorState> instance
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
}

class ScaffoldKeyHolder {
  // Private constructor
  ScaffoldKeyHolder._privateConstructor();

  // Static private instance of the class
  static final ScaffoldKeyHolder _instance =
      ScaffoldKeyHolder._privateConstructor();

  // Factory constructor to return the same instance
  factory ScaffoldKeyHolder() {
    return _instance;
  }

  // The GlobalKey<NavigatorState> instance
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'scaffoldState');
}

final GlobalKey<NavigatorState> rootNavigatorKey =
    NavigatorKeyHolder().rootNavigatorKey;

GoRouter createGoRouter() {
  final GlobalKey<NavigatorState> navbarShellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'navbar');
  final GlobalKey<NavigatorState> bottomSheetNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'navbar');

  return GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    routes: [
      ShellRoute(
        parentNavigatorKey: rootNavigatorKey,
        navigatorKey: navbarShellNavigatorKey,
        pageBuilder: (context, state, child) =>
            MaterialPage<void>(child: NavbarWrapper(child: child)),
        routes: [
          GoRoute(
            parentNavigatorKey: navbarShellNavigatorKey,
            path: '/image_picker/:image_path',
            name: '/image_picker',
            pageBuilder: (context, state) {
              final imagePath = state.pathParameters["image_path"];
              assert(imagePath != null);

              // String encodedJsonString = Uri.encodeComponent(imagePath!);

              log('JSON Decode: ${jsonDecode(imagePath!)[0]}');

              return CustomTransitionPage(
                transitionDuration: const Duration(milliseconds: 800),
                key: state.pageKey,
                child: ImagePicker(
                  paths: jsonDecode(imagePath),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCirc)
                      .animate(animation),
                  child: child,
                ),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: navbarShellNavigatorKey,
            path: '/memory/:memory_id',
            name: '/memory',
            pageBuilder: (context, state) {
              final memoryId = state.pathParameters["memory_id"];
              assert(memoryId != null);

              log('Memory Id: $memoryId');

              return CustomTransitionPage(
                transitionDuration: const Duration(milliseconds: 800),
                key: state.pageKey,
                child: Memory(
                  memoryId: int.parse(memoryId!),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCirc)
                      .animate(animation),
                  child: child,
                ),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: navbarShellNavigatorKey,
            path: '/',
            name: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
              transitionDuration: const Duration(milliseconds: 800),
              key: state.pageKey,
              child: const Home(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return _slideFromBottom(animation, secondaryAnimation, child);

                // Define a tween for slightly scaling up the child
              },
            ),
          ),
          GoRoute(
            parentNavigatorKey: navbarShellNavigatorKey,
            path: '/random-memory',
            name: '/random-memory',
            pageBuilder: (context, state) => CustomTransitionPage(
              transitionDuration: const Duration(milliseconds: 800),
              key: state.pageKey,
              child: const Random(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return _slideFromBottom(animation, secondaryAnimation, child);
              },
            ),
          ),
          GoRoute(
            parentNavigatorKey: navbarShellNavigatorKey,
            path: '/settings',
            name: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              transitionDuration: const Duration(milliseconds: 800),
              key: state.pageKey,
              child: const Settings(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return _slideFromBottom(animation, secondaryAnimation, child);
              },
            ),
          ),
          GoRoute(
            parentNavigatorKey: navbarShellNavigatorKey,
            path: '/favorites',
            name: '/favorites',
            pageBuilder: (context, state) => CustomTransitionPage(
              transitionDuration: const Duration(milliseconds: 800),
              key: state.pageKey,
              child: const Favorite(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Define a tween for scaling from a smaller size
                final currentRoute = GoRouter.of(context)
                    .routerDelegate
                    .currentConfiguration
                    .uri
                    .toString();

                return _slideFromBottom(animation, secondaryAnimation, child);
              },
            ),
          ),
          // ShellRoute(
          //   parentNavigatorKey: navbarShellNavigatorKey,
          //   navigatorKey: bottomSheetNavigatorKey,
          //   pageBuilder: (context, state, child) =>
          //       MaterialPage<void>(child: BottomNavWrapper(child: child)),
          //   routes: [
          //
          //   ],
          // )
        ],
      ),
    ],
  );
}

AnimatedBuilder _slideFromRight(Animation animation, Widget child) {
  // Define a tween for slightly scaling up the child
  // Define a tween for 3D-like rotation effect
  var rotationTween = Tween(begin: -0.1, end: 0.0).chain(
    CurveTween(curve: Curves.easeOut),
  );

  // Define a tween for slightly scaling up the child
  var scaleTween = Tween(begin: 0.9, end: 1.0).chain(
    CurveTween(curve: Curves.easeOut),
  );

  // Drive the animations with the defined tweens
  var rotationAnimation = animation.drive(rotationTween);
  var scaleAnimation = animation.drive(scaleTween);

  // Apply a transformation for both rotation and scale
  return AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      return Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateY(rotationAnimation.value)
          ..scale(scaleAnimation.value),
        alignment: Alignment.center,
        child: child,
      );
    },
  );
}

Widget _slideFromBottom(Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  // Scale animation for the incoming screen
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

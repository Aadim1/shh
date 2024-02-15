import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shh/provider.dart';
import 'package:shh/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'color_scheme.dart';

Future<void> main() async {
  await Supabase.initialize(url: url, anonKey: anonKey);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(getGoRouterProvider);

    return MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      title: "App",
      theme: ThemeData(
          colorScheme: lightSlateBlueThemeColors(), useMaterial3: true),
      routeInformationProvider: router.routeInformationProvider,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
    );
  }
}

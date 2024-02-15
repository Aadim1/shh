import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shh/router.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
GlobalKey<NavigatorState> getRootNavigatorKey(GetRootNavigatorKeyRef ref) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      NavigatorKeyHolder().rootNavigatorKey;
  return rootNavigatorKey;
}

@Riverpod(keepAlive: true)
GoRouter getGoRouter(GetGoRouterRef ref) {
  return createGoRouter();
}

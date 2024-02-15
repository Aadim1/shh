// import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shh/router.dart';

void showInfoDialogWithAction(
    String message, String title, Function() callback) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Center(
            child: Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                callback();
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
  }
}

void showInfoDialog(String message, String title) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Center(
            child: Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
  }
}

void showMultiActionDialog(String title, String message,
    List<Function()> callbacks, List<String> actions) {
  assert(callbacks.length == actions.length);
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }

  List<Widget> actionWidgets = [];

  for (int i = 0; i < actions.length; i++) {
    final action = actions[i];
    actionWidgets.add(
      TextButton(
        onPressed: () {
          Navigator.of(context).context.pop();
          callbacks[i]();
        },
        child: Text(action),
      ),
    );
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: actionWidgets,
        );
      },
    );
  }
}

void showActionDialog(String title, String message, Function() callback) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                callback();
              },
              child: const Text("Yes"),
            )
          ],
        );
      },
    );
  }
}

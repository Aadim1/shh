import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shh/custom_text_field.dart';
import 'package:shh/supabase.dart';

import '../dialog.dart';
import '../router.dart';

class UpdateName extends HookWidget {
  final String currentName;
  final int memoryId;

  const UpdateName({
    super.key,
    required this.currentName,
    required this.memoryId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: currentName);
    return Column(
      children: [
        CustomTextField(
          hintText: "Memory Name",
          controller: controller,
          prefixIcon: const Icon(Icons.person),
          onChange: (newValue) {
            // currentName = newValue;
          },
          onSubmitted: (newValue) {
            // currentName.value = newValue;
          },
        ),
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 60,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.background,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  if (controller.text.isEmpty) {
                    showInfoDialog("Warning", 'Not a valid name.');
                    return;
                  }

                  log('Onward... ${controller.text}');
                  await supabase.from("memory").update({
                    "memory_name": controller.text,
                  }).match({
                    "id": memoryId,
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Update"),
              ),
            ),
          ],
        )
      ],
    );
  }
}

void showUpdateName(String currentName, int memoryId) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }
  showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    isScrollControlled: true,
    builder: (context) {
      return UpdateName(currentName: currentName, memoryId: memoryId);
    },
  );
}

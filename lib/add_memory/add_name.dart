import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shh/custom_text_field.dart';

import '../dialog.dart';

class AddName extends HookWidget {
  final ValueNotifier<String> currentName;
  final ValueNotifier<int> currentStage;

  const AddName({
    super.key,
    required this.currentName,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: currentName.value);
    return Column(
      children: [
        CustomTextField(
          hintText: "Memory Name",
          controller: controller,
          prefixIcon: const Icon(Icons.person),
          onChange: (newValue) {
            currentName.value = newValue;
          },
          onSubmitted: (newValue) {
            currentName.value = newValue;
          },
        ),
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 150,
              height: 60,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondaryContainer,
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
                  currentStage.value--;
                },
                child: const Text("Previous"),
              ),
            ),
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

                  log('Onward...');
                  currentName.value = controller.text;
                  currentStage.value++;
                },
                child: const Text("Next"),
              ),
            ),
          ],
        )
      ],
    );
  }
}

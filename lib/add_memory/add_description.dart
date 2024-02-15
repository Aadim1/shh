import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shh/custom_text_field.dart';

import '../dialog.dart';

class AddDescription extends HookWidget {
  final ValueNotifier<String> currentDescription;
  final ValueNotifier<int> currentStage;

  const AddDescription({
    super.key,
    required this.currentDescription,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: currentDescription.value);
    return Column(
      children: [
        CustomTextField(
          hintText: "Memory description: ",
          controller: controller,
          prefixIcon: const Icon(Icons.person),
          onChange: (newValue) {
            currentDescription.value = newValue;
          },
          onSubmitted: (newValue) {
            currentDescription.value = newValue;
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
                    showActionDialog("Warning",
                        'Are you sure you want to continue without description',
                        () {
                      currentDescription.value = controller.text;
                      currentStage.value++;
                    });
                    return;
                  }

                  log('Onward...');
                  currentDescription.value = controller.text;
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

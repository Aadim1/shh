import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shh/custom_text_field.dart';
import 'package:shh/supabase.dart';

import '../router.dart';

class UpdateDescription extends HookWidget {
  final String currentDescription;
  final int memoryId;

  const UpdateDescription({
    super.key,
    required this.currentDescription,
    required this.memoryId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: currentDescription);
    return Column(
      children: [
        CustomTextField(
          hintText: "Memory Description",
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
                  await supabase.from("memory").update({
                    "description": controller.text,
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

void showUpdateDescription(String currentDescription, int memoryId) {
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
      return Column(
        children: [
          Text(
            "Change Memory Description",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          UpdateDescription(
              currentDescription: currentDescription, memoryId: memoryId),
        ],
      );
    },
  );
}

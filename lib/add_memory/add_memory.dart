import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shh/add_memory/add_date_time.dart';
import 'package:shh/add_memory/add_name.dart';
import 'package:shh/add_memory/add_people.dart';
import 'package:shh/add_memory/summary.dart';

import '../router.dart';
import 'add_description.dart';
import 'add_image.dart';

List<Widget> _getStages({
  required ValueNotifier<List<Uint8List>> imageBytes,
  required ValueNotifier<int> currentStage,
  required ValueNotifier<String> currentName,
  required ValueNotifier<DateTime?> currentDateTime,
  required ValueNotifier<List<int>> currentPeople,
  required ValueNotifier<String> currentDescription,
}) {
  return [
    AddImage(
      imageBytes: imageBytes,
      currentStage: currentStage,
    ),
    AddName(
      currentName: currentName,
      currentStage: currentStage,
    ),
    AddDescription(
      currentDescription: currentDescription,
      currentStage: currentStage,
    ),
    AddDateTime(
      currentDateTime: currentDateTime,
      currentStage: currentStage,
    ),
    AddPeople(
      currentPeople: currentPeople,
      currentStage: currentStage,
    ),
    Summary(
      currentPeople: currentPeople,
      currentStage: currentStage,
      imageBytes: imageBytes,
      currentDateTime: currentDateTime,
      currentName: currentName,
      currentDescription: currentDescription,
    ),
  ];
}

class _AddMemory extends HookWidget {
  const _AddMemory({super.key});

  @override
  Widget build(BuildContext context) {
    final currentStage = useState<int>(0);
    final imageBytes = useState<List<Uint8List>>([]);
    final currentName = useState<String>('');
    final currentDateTime = useState<DateTime?>(null);
    final currentPeople = useState<List<int>>([]);
    final currentDescription = useState<String>('');

    final stages = _getStages(
      imageBytes: imageBytes,
      currentStage: currentStage,
      currentName: currentName,
      currentDateTime: currentDateTime,
      currentPeople: currentPeople,
      currentDescription: currentDescription,
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Text(
                "Add Memory",
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                width: 35,
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: stages[currentStage.value],
          ),
        ],
      ),
    );
  }
}

void showAddMemory() {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return;
  }
  showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.height * 0.95,
    ),
    isScrollControlled: true,
    builder: (context) {
      return const _AddMemory();
    },
  );
}

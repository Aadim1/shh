import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../dialog.dart';

class AddDateTime extends HookWidget {
  final ValueNotifier<DateTime?> currentDateTime;
  final ValueNotifier<int> currentStage;

  const AddDateTime({
    super.key,
    required this.currentStage,
    required this.currentDateTime,
  });

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoDatePicker(
            initialDateTime: DateTime.now(),
            onDateTimeChanged: (DateTime newDate) {
              currentDateTime.value = newDate;
            },
            mode: CupertinoDatePickerMode.dateAndTime, // Change as needed
            use24hFormat: true, // For 24-hour format, adjust as needed
            minuteInterval: 1, // Interval between minutes, adjust as needed
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: Colors.black,
            ),
          ),
          padding: const EdgeInsets.all(15.0),
          child: currentDateTime.value == null
              ? const Text("Not Yet Selected")
              : Text(
                  "${DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime.value!)}"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => currentDateTime.value = null,
              child: const Text("Remove Selected Date and time"),
            ),
            TextButton(
              onPressed: () => _showDatePicker(context),
              child: const Text("Select Date and time"),
            ),
          ],
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
                  if (currentDateTime.value == null) {
                    showActionDialog("Warning",
                        'Are you sure you do not want to add Date and time?.',
                        () {
                      currentStage.value++;
                    });
                    return;
                  }
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

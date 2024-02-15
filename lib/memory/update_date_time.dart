import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../dialog.dart';
import '../router.dart';
import '../supabase.dart';

StreamSubscription? dateTimeStream;

class UpdateDateTime extends HookWidget {
  final DateTime? currentDateTime;
  final int memoryId;

  const UpdateDateTime({
    super.key,
    required this.currentDateTime,
    required this.memoryId,
  });

  void _showDatePicker(BuildContext context, ValueNotifier dateTime) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoDatePicker(
            initialDateTime: DateTime.now(),
            onDateTimeChanged: (DateTime newDate) {
              dateTime.value = newDate;
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
    final dateTime = useState<DateTime?>(currentDateTime);

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
          child: dateTime.value == null
              ? const Text("Not Yet Selected")
              : Text(
                  "${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.value!)}"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => dateTime.value = null,
              child: const Text("Remove Selected Date and time"),
            ),
            TextButton(
              onPressed: () => _showDatePicker(context, dateTime),
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
                  if (dateTime.value == null) {
                    showActionDialog("Warning",
                        'Are you sure you do not want to add Date and time?.',
                        () async {
                      await supabase.from("memory").update({
                        "date_": null,
                      }).match({
                        "id": memoryId,
                      });
                    });
                    return;
                  }
                  await supabase.from("memory").update({
                    "date_": dateTime.value?.toIso8601String(),
                  }).match({
                    "id": memoryId,
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        )
      ],
    );
  }
}

void showUpdateDateTime(DateTime? currentDateTime, int memoryId) {
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
          Text("Update Date and Time"),
          const SizedBox(
            height: 30,
          ),
          UpdateDateTime(currentDateTime: currentDateTime, memoryId: memoryId),
        ],
      );
    },
  );
}

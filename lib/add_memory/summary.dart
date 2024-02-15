import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:uuid/uuid.dart';

import '../dialog.dart';
import '../supabase.dart';

class Summary extends HookWidget {
  final ValueNotifier<List<int>> currentPeople;
  final ValueNotifier<int> currentStage;
  final ValueNotifier<List<Uint8List>> imageBytes;
  final ValueNotifier<String> currentName;
  final ValueNotifier<String> currentDescription;
  final ValueNotifier<DateTime?> currentDateTime;

  const Summary({
    super.key,
    required this.currentPeople,
    required this.currentStage,
    required this.imageBytes,
    required this.currentDateTime,
    required this.currentName,
    required this.currentDescription,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState<bool>(false);

    final pageController = usePageController(
      viewportFraction: 0.8,
      keepPage: true,
      initialPage: 0,
    );

    Widget image = Container(
      height: 300,
      width: 300,
      color: Colors.white,
      child: const Center(child: Text("No Image Added...")),
    );

    if (imageBytes.value.isNotEmpty) {
      image = SizedBox(
        height: 250,
        width: 400,
        child: PageView.builder(
          controller: pageController,
          itemCount: imageBytes.value.length,
          pageSnapping: true,
          itemBuilder: (context, pagePosition) {
            return Container(
              margin: const EdgeInsets.all(10.0),
              child: Image.memory(
                imageBytes.value[pagePosition % imageBytes.value.length],
              ),
            );
          },
        ),
      );
    }

    Future<void> addNewMemory() async {
      var uuid = const Uuid();
      try {
        final memoryResponse = await supabase.from("memory").insert({
          "memory_name": currentName.value,
          "date_": currentDateTime.value?.toIso8601String(),
          "description": currentDescription.value
        }).select('id');
        if (memoryResponse.isEmpty) {
          showInfoDialog("Failed", "Error");
          return;
        }
        final memoryId = memoryResponse[0]["id"];

        for (int i = 0; i < currentPeople.value.length; i++) {
          await supabase.from("memory_people").insert({
            "memory_id": memoryId,
            "people_id": currentPeople.value[i],
          });
        }

        for (int i = 0; i < imageBytes.value.length; i++) {
          final String uuidV1 = uuid.v1();
          await supabase.from("memory_pictures").insert(
              {"storage_path": "memory/$uuidV1.png", "memory_id": memoryId});
          await supabase.storage
              .from("private")
              .uploadBinary('memory/$uuidV1.png', imageBytes.value[i]);
        }
        if (context.mounted) {
          showInfoDialog("New Memory Added.", "Success");
          Navigator.of(context).pop();
        }
      } catch (e) {
        log("Error $e");
        showInfoDialog("Failed", "Error");
        return;
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                image,
                imageBytes.value.isNotEmpty
                    ? SmoothPageIndicator(
                        controller: pageController,
                        count: imageBytes.value.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          type: WormType.normal,
                        ),
                      )
                    : const SizedBox.shrink(),
                TextButton(
                  onPressed: () {
                    currentStage.value = 0;
                  },
                  child: Text("Edit Images"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Memory name ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Text(currentName.value),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            currentStage.value = 1;
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Date ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Text(
                          currentDateTime.value == null
                              ? "Not Provided"
                              : DateFormat("yyyy-MM-dd")
                                  .format(currentDateTime.value!),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            currentStage.value = 3;
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Time ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Text(
                          currentDateTime.value == null
                              ? "Not Provided"
                              : DateFormat("h:mm a")
                                  .format(currentDateTime.value!),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            currentStage.value = 3;
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Peoples ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Text("${currentPeople.value.length}"),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            currentStage.value = 4;
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Memory Description ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => currentStage.value = 2,
                              icon: const Icon(Icons.edit),
                              iconSize: 16,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "\"${currentDescription.value}\"",
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: 300,
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
              showActionDialog("Info", 'Are you sure? You want to add memory',
                  () async {
                isLoading.value = true;
                await addNewMemory();
                isLoading.value = false;
              });
            },
            child: isLoading.value
                ? const CupertinoActivityIndicator(
                    radius: 16,
                    color: Colors.white,
                  )
                : const Text("Submit"),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

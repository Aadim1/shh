import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../dialog.dart';

class AddImage extends HookWidget {
  final ValueNotifier<List<Uint8List>> imageBytes;
  final ValueNotifier<int> currentStage;

  const AddImage({
    super.key,
    required this.imageBytes,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    final pageController = usePageController(
      viewportFraction: 0.8,
      keepPage: true,
      initialPage: 0,
    );

    Widget image = Container(
      height: 250,
      width: 400,
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
            return Stack(
              children: [
                Container(
                  height: 250,
                  width: 400,
                  margin: const EdgeInsets.all(10.0),
                  child: Image.memory(
                    imageBytes.value[pagePosition % imageBytes.value.length],
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        imageBytes.value = [
                          ...imageBytes.value..removeAt(pagePosition)
                        ];
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return Column(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                final imagePick =
                    await picker.pickImage(source: ImageSource.gallery);
                if (imagePick == null) {
                  showInfoDialog("No image was selected.", "Warning");
                  return;
                }
                final imageByte = await imagePick.readAsBytes();
                imageBytes.value = [...imageBytes.value, imageByte];
              },
              child: const Text("Select a image"),
            ),
          ],
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
              if (imageBytes.value.isEmpty) {
                showActionDialog("Warning",
                    'Are you sure you will like to proceed without image?', () {
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
    );
  }
}

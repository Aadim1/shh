import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ImagePicker extends HookWidget {
  final List<dynamic> paths;
  const ImagePicker({super.key, required this.paths});

  @override
  Widget build(BuildContext context) {
    log('Paths: $paths ${paths.length}');

    final pageController = usePageController(
      viewportFraction: 0.8,
      keepPage: true,
      initialPage: 0,
    );

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(35),
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 300,
                  width: 500,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: paths.length,
                    pageSnapping: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          child: Image.network(
                            paths[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

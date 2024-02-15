import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../hero.dart';

class Favorite extends HookWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Favorite Memories",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          context.pushNamed('/memory', pathParameters: {
                            "memory_id": '$index',
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: index % 2 == 0
                                      ? const Icon(
                                          Icons.favorite_border_outlined,
                                        )
                                      : const Icon(
                                          Icons.favorite,
                                          color: Colors.redAccent,
                                        ),
                                ),
                                getHero(index, ""),
                                const Spacer(
                                  flex: 1,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      "Knotts",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                    Container(
                                      width:
                                          180, // Use the maximum width available
                                      height:
                                          60, // Adjust the height according to your needs
                                      child: const Text(
                                        "\"We went to Knotts berry farm, and had a blast. This is so good my name is there sdhui aghiou sahdou ho\" ",
                                        overflow: TextOverflow
                                            .ellipsis, // Add ellipsis when text overflows
                                        softWrap: true, // Enable text wrapping
                                        maxLines:
                                            2, // Adjust the number of lines to fit the container height
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.pushNamed('/memory',
                                        pathParameters: {
                                          "memory_id": "$index"
                                        });
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shh/home/home_provider.dart';
import 'package:shh/supabase.dart';

import '../hero.dart';

class RecentMemories extends HookConsumerWidget {
  const RecentMemories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      return;
    }, []);

    final rangeProvider = ref.watch(getRecentMemoriesRangeProvider);

    final recentServices = ref.watch(getRecentServiceProvider);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            RefreshIndicator(
                onRefresh: () async {
                  ref.read(getRecentMemoriesRangeProvider.notifier).reset();
                },
                child: recentServices.when(
                  data: (value) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final memory = value[index];
                        final memoryId = memory["id"];
                        final pictures = memory["memory_pictures"];
                        final memoryName = memory["memory_name"];

                        log('Memory: $memory $memoryName');

                        return HookBuilder(builder: (context) {
                          final picture = useState<String>(
                              "https://wsnzyaidtndgtohmgwap.supabase.co/storage/v1/object/public/private/memory/default_memory.png");

                          useEffect(() {
                            Future<void> getPic() async {
                              if (pictures.isNotEmpty) {
                                final path = pictures[0]["storage_path"];
                                picture.value = await supabase.storage
                                    .from('private')
                                    .getPublicUrl("$path");
                              }
                            }

                            getPic();
                            return;
                          }, []);

                          return GestureDetector(
                            onTap: () {
                              context.pushNamed('/memory', pathParameters: {
                                "memory_id": '$memoryId',
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
                                      onPressed: () async {
                                        final isFavorite =
                                            memory["is_favorite"];
                                        await supabase.from("memory").update({
                                          "is_favorite": !isFavorite
                                        }).match({"id": memoryId});
                                      },
                                      icon: memory["is_favorite"]
                                          ? const Icon(
                                              Icons.favorite_border_outlined,
                                            )
                                          : const Icon(
                                              Icons.favorite,
                                              color: Colors.redAccent,
                                            ),
                                    ),
                                    getHero(memoryId, picture.value),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          memoryName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                        ),
                                        SizedBox(
                                          width:
                                              180, // Use the maximum width available
                                          height:
                                              60, // Adjust the height according to your needs
                                          child: Text(
                                            "\"${memory["description"]}\" ",
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow
                                                .ellipsis, // Add ellipsis when text overflows
                                            softWrap:
                                                true, // Enable text wrapping
                                            maxLines:
                                                2, // Adjust the number of lines to fit the container height
                                            style: const TextStyle(
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
                                              "memory_id": "$memoryId"
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
                        });
                      },
                    );
                  },
                  error: (e, ee) => Text("There was an error $e $ee"),
                  loading: () => const CupertinoActivityIndicator(),
                )),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shh/memory/update_date_time.dart';
import 'package:shh/memory/update_description.dart';
import 'package:shh/memory/update_name.dart';
import 'package:shh/memory/update_people.dart';
import 'package:shh/supabase.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

StreamSubscription? memoryStream;
StreamSubscription? _memoryPeoplStream;

class Memory extends HookWidget {
  final int memoryId;

  const Memory({super.key, required this.memoryId});

  @override
  Widget build(BuildContext context) {
    final person = useRef<Map<String, dynamic>?>(null);
    final images = useState<List<String>>([
      "https://wsnzyaidtndgtohmgwap.supabase.co/storage/v1/object/public/private/memory/default_memory.png"
    ]);

    Future<void> loadImages(paths) async {
      final List<String> loadedImages = [];
      for (var storagePath in paths) {
        // Example person identifier for image name
        log('object ${storagePath} h');

        final String image = await supabase.storage
            .from('private')
            .getPublicUrl('$storagePath'); // Ensure correct image identifier

        log('Memory Image: $image');

        loadedImages.add(image);
      }
      images.value = loadedImages;
    }

    useEffect(() {
      memoryStream?.cancel();
      memoryStream = supabase
          .from("memory")
          .stream(primaryKey: ['id'])
          .eq('id', memoryId)
          .listen(
            (event) async {
              log('Something Changed....');

              final resp = await supabase
                  .from("memory")
                  .select(
                      "id, memory_name,date_, description, is_favorite, memory_pictures(memory_id, storage_path), memory_people(memory_id, people_id)")
                  .eq('id', memoryId)
                  .limit(1);

              person.value = resp[0];
              loadImages(person.value!['memory_pictures']
                  .map<String>((picture) => picture['storage_path'] as String)
                  .toList());
            },
          );
      _memoryPeoplStream = supabase
          .from("memory_people")
          .stream(primaryKey: ['id'])
          .eq('memory_id', memoryId)
          .listen(
            (event) async {
              log('Something Changed....');

              final resp = await supabase
                  .from("memory")
                  .select(
                      "id, memory_name,date_, description, is_favorite, memory_pictures(memory_id, storage_path), memory_people(memory_id, people_id)")
                  .eq('id', memoryId)
                  .limit(1);

              person.value = resp[0];
              loadImages(person.value!['memory_pictures']
                  .map<String>((picture) => picture['storage_path'] as String)
                  .toList());
            },
          );
      return () {
        log("Stream Closed...");
        memoryStream?.cancel();
        _memoryPeoplStream?.cancel();
      };
    }, []);

    if (person.value == null) {
      return const CupertinoActivityIndicator();
    }

    final isFavorite = useState<bool>(person.value!["is_favorite"]);

    final memory = person.value!;
    final pageController = usePageController(
      viewportFraction: 0.8,
      keepPage: true,
      initialPage: 0,
    );

    log('Memory Date: ${memory['date_'] == null}');

    List<int> peopleIds = memory['memory_people']
        .map<int>((item) => item['people_id'] as int)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(50.0)),
                child: Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    color: Theme.of(context).colorScheme.primary,
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // getHero(memoryId, context, images.value[0], images.value),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: images.value.length,
              pageSnapping: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    log("Pressed the image");
                    context.pushNamed("/image_picker", pathParameters: {
                      "image_path": jsonEncode(images.value)
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Image.network(
                      images.value[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: pageController,
            count: images.value.length,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              type: WormType.normal,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () async {
                await supabase.from("memory").update(
                    {"is_favorite": !isFavorite.value}).match({"id": memoryId});
                isFavorite.value = !isFavorite.value;
              },
              icon: !isFavorite.value
                  ? const Icon(Icons.favorite_border_outlined)
                  : const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                    ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showUpdateName(memory["memory_name"], memoryId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(2.0),
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
                            Text("${memory["memory_name"]}"),
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                log("Show Update Name");
                                showUpdateName(memory["memory_name"], memoryId);
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
                              "Date ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          memory["date_"] != null
                              ? Text(DateFormat("yyyy-MM-dd")
                                  .format(DateTime.parse(memory["date_"])))
                              : Text("Not Provided"),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showUpdateDateTime(
                                  memory["date_"] == null
                                      ? null
                                      : DateTime.parse(memory['date_']),
                                  memoryId);
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
                              "Time ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          memory["date_"] != null
                              ? Text(DateFormat("hh:mm a")
                                  .format(DateTime.parse(memory["date_"])))
                              : Text("Not Provided"),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showUpdateDateTime(
                                  memory["date_"] == null
                                      ? null
                                      : DateTime.parse(memory['date_']),
                                  memoryId);
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
                          Text('${peopleIds.length}'),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showUpdatePeople(peopleIds, memoryId);
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                onPressed: () {
                                  showUpdateDescription(
                                      memory["description"], memoryId);
                                },
                                icon: const Icon(Icons.edit),
                                iconSize: 20,
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "\"${memory["description"]}\"",
                                style: TextStyle(fontStyle: FontStyle.italic),
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
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

Widget getHero(
    int memoryId, BuildContext context, String url, List<String> paths) {
  return GestureDetector(
    onTap: () {
      log("Pressed the image");
      context.pushNamed("/image_picker",
          pathParameters: {"image_path": jsonEncode(paths)});
    },
    child: Hero(
      tag: "image-$memoryId",
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onTap: () {
                  log("Pressed the image");
                  context.pushNamed("/image_picker",
                      pathParameters: {"image_path": jsonEncode(paths)});
                },
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width * 0.5,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(0.0)),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(0.0)),
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.of(context).pop(),
                            color: Theme.of(context).colorScheme.primary,
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                log("Pressed the image");
                context.pushNamed("/image_picker",
                    pathParameters: {"image_path": jsonEncode(paths)});
              },
              child: Container(
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(0.0)),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shh/add_person/add_person.dart';
import 'package:shh/supabase.dart';

import '../router.dart';

StreamSubscription? peopleStream;

class UpdatePeople extends HookWidget {
  final int memoryId;
  final List<int> peopleIds;

  const UpdatePeople({
    super.key,
    required this.memoryId,
    required this.peopleIds,
  });

  @override
  Widget build(BuildContext context) {
    final persons = useRef<List<Map<String, dynamic>>>([]);
    final images = useState<List<String>>([]);

    Future<void> loadImages() async {
      final List<String> loadedImages = [];
      for (var person in persons.value) {
        log('object ${person["image_supabase_storage_path"]} h');

        final String image = supabase.storage.from('private').getPublicUrl(
            '${person["image_supabase_storage_path"]}'); // Ensure correct image identifier

        log('Image: $image');

        loadedImages.add(image);
      }
      images.value = loadedImages;
    }

    useEffect(() {
      Future<void> init() async {
        persons.value = await supabase.from('people').select("*");
        await loadImages();
        log('Inside init: ${persons.value}');
      }

      peopleStream?.cancel();
      peopleStream = supabase
          .from('people')
          .stream(primaryKey: ['id'])
          .order('id')
          .listen((event) async {
            log('message $event');
            persons.value = event;
            await loadImages();
          });

      init();
      return () {
        peopleStream?.cancel();
      };
    }, []);

    return Column(
      children: [
        TextButton(
          onPressed: () {
            showAddPerson();
          },
          child: const Text("Add new person"),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
                children: persons.value.asMap().entries.map((entry) {
              final index = entry.key;
              final person = entry.value;

              final id = person["id"];

              // log('Person $person');

              return Row(
                children: [
                  CupertinoCheckbox(
                      value: peopleIds.contains(id),
                      onChanged: (newVal) async {
                        if (newVal == null || !newVal) {
                          await supabase.from("memory_people").delete().match({
                            "memory_id": memoryId,
                            "people_id": id,
                          });
                        } else {
                          await supabase.from("memory_people").insert({
                            "memory_id": memoryId,
                            "people_id": id,
                          });
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        images.value[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${person["people_name"]}",
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              );
            }).toList()),
          ),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     SizedBox(
        //       width: 150,
        //       height: 60,
        //       child: ElevatedButton(
        //         style: ButtonStyle(
        //           backgroundColor: MaterialStateProperty.all(
        //             Theme.of(context).colorScheme.primary,
        //           ),
        //           foregroundColor: MaterialStateProperty.all(
        //             Theme.of(context).colorScheme.background,
        //           ),
        //           shape: MaterialStateProperty.all(
        //             RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(10.0),
        //             ),
        //           ),
        //         ),
        //         onPressed: () async {
        //           if (currentPeople.value.isEmpty) {
        //             showActionDialog("Warning",
        //                 'Are you sure you don\'t want to add anyone here?', () {
        //               currentStage.value++;
        //             });
        //             return;
        //           }
        //           currentStage.value++;
        //         },
        //         child: const Text("Next"),
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

void showUpdatePeople(List<int> peopleIds, int memoryId) {
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
      return Container(
          width: MediaQuery.of(context).size.width,
          child: UpdatePeople(peopleIds: peopleIds, memoryId: memoryId));
    },
  );
}

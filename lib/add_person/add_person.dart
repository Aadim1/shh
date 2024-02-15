import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shh/custom_text_field.dart';
import 'package:shh/dialog.dart';
import 'package:shh/router.dart';
import 'package:shh/supabase.dart';

class _AddPerson extends HookWidget {
  const _AddPerson({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    final personNameController = useTextEditingController(text: '');
    final name = useState<String>('');
    final isLoading = useState(false);

    final imageFile = useState<XFile?>(null);
    final imageBytes = useState<Uint8List?>(null);

    Future<void> addPersonToDB() async {
      dynamic id;

      try {
        final currentBytes = imageBytes.value;
        final personName = personNameController.text;
        final resp = await supabase
            .from("people")
            .insert({"people_name": personName}).select();

        if (resp.isEmpty) {
          showInfoDialog("Failed to insert.", "Error");
          return;
        }
        final person = resp[0];
        id = person["id"];

        if (currentBytes != null) {
          final String path = await supabase.storage
              .from("private")
              .uploadBinary("person/$id.png", currentBytes);
          await supabase
              .from("people")
              .update({"image_supabase_storage_path": "person/$id.png"}).match(
                  {"id": id});
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        await supabase.from("people").delete().match({"id": id});
        await supabase.storage.from("private").remove(['person/$id.png']);
        log('Error $e');
        showInfoDialog("There was an error. Contact Me.", "Error");
      }
    }

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
                "Add Person",
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
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: imageBytes.value != null
                  ? Image.memory(
                      imageBytes.value!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      'https://wsnzyaidtndgtohmgwap.supabase.co/storage/v1/object/public/private/person/default_person.png',
                      fit: BoxFit.fill,
                    ),
            ),
          ),
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
                  imageFile.value = imagePick;
                  imageBytes.value = await imagePick.readAsBytes();
                },
                child: const Text("Select a image"),
              ),
              TextButton(
                onPressed: () async {
                  imageFile.value = null;
                  imageBytes.value = null;
                },
                child: const Text("Remove selected image"),
              ),
            ],
          ),
          CustomTextField(
            hintText: 'Person Name',
            controller: personNameController,
            prefixIcon: const Icon(Icons.person),
            onChange: (String newValue) {
              name.value = newValue;
            },
            onSubmitted: (String newValue) {
              name.value = newValue;
            },
          ),
          const SizedBox(
            height: 30,
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
                if (personNameController.text.trim().isEmpty) {
                  showInfoDialog("Need a valid name.", "Warning");
                  return;
                }

                isLoading.value = true;

                if (imageFile.value == null) {
                  showActionDialog(
                      "Warning", "Are you sure you don't want to add picture?",
                      () async {
                    await addPersonToDB();
                    isLoading.value = false;
                    return;
                  });
                  return;
                }
                await addPersonToDB();
                isLoading.value = false;
              },
              child: isLoading.value
                  ? const CupertinoActivityIndicator(
                      radius: 18,
                      color: Colors.white,
                    )
                  : const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}

void showAddPerson() {
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
      return const _AddPerson();
    },
  );
}

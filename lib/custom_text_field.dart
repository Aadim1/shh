import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends HookWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final int maxAllowed;
  final Icon prefixIcon;
  final Function(String value) onChange;
  final void Function(String value) onSubmitted;
  final bool isMultiLine;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.textInputType = TextInputType.text,
    this.maxAllowed = 1000,
    required this.prefixIcon,
    required this.onChange,
    required this.onSubmitted,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final controllerFocusNode = useFocusNode();

    void onTextChanged(String value) {
      String text = controller.text;
      // Remove non-digits and limit to maximum 10 characters
      String filteredText = text;

      if (textInputType == TextInputType.phone) {
        filteredText = text.replaceAll(RegExp(r'[^0-9]'), '');
      }

      if (filteredText.length > maxAllowed) {
        filteredText = filteredText.substring(
          0,
          maxAllowed,
        ); // Keep only the first 10 digits
      }

      // log('${text != filteredText}');

      if (text != filteredText) {
        controller.value = TextEditingValue(
          text: filteredText,
          // Try to keep the cursor at the end of the existing text
          selection: TextSelection.collapsed(offset: filteredText.length),
        );
      }
      onChange(value);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                hintText,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              maxLines: null,
              focusNode: controllerFocusNode,
              onTapOutside: (event) {
                if (controllerFocusNode.hasFocus) {
                  log('Is this being triggered????');

                  // Unfocus the TextField
                  FocusManager.instance.primaryFocus?.unfocus();

                  // Execute the desired function
                  onSubmitted(controller.text);
                }
              },
              onSubmitted: (newValue) {
                onSubmitted(newValue);
              },
              onChanged: (newValue) => onTextChanged(newValue),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer, // Color when the TextField is focused
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    width: 2.0,
                  ),
                ),
                prefixIcon: prefixIcon,
                hintText: hintText,
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

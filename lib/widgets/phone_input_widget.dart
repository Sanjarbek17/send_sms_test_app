import 'package:flutter/material.dart';

class PhoneInputWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final String label;

  const PhoneInputWidget({
    Key? key,
    required this.phoneController,
    this.label = "Phone Number",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure +998 is present at the start
    if (!phoneController.text.startsWith('+998')) {
      phoneController.text = '+998';
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length),
      );
    }

    return TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        hintText: "Enter phone number",
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.phone),
      ),
      maxLength: 13, // +998XXXXXXXXX
      onChanged: (value) {
        if (!value.startsWith('+998')) {
          phoneController.text = '+998';
          phoneController.selection = TextSelection.fromPosition(
            TextPosition(offset: phoneController.text.length),
          );
        }
      },
    );
  }
}

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
    return TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        hintText: "Enter phone number",
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.phone),
      ),
    );
  }
}

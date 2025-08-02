import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/file_service.dart';

class FilePickerWidget extends StatelessWidget {
  final String label;
  final Function(List<Contact>, String) onFilePicked;

  const FilePickerWidget({
    Key? key,
    required this.label,
    required this.onFilePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(40, 60),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color.fromARGB(255, 150, 149, 149),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              List<Contact>? contacts = await FileService.pickContactsFile();
              if (contacts != null) {
                onFilePicked(contacts, "File selected");
              }
            },
            child: const Text("Pick a file"),
          ),
        ),
        Expanded(
          flex: 7,
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              label: Text(label),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

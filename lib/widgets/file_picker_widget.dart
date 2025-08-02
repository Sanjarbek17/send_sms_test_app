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
    final bool hasFile = label != "No file selected";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? Colors.green[300]! : Colors.grey[300]!,
          width: 2,
        ),
        color: hasFile ? Colors.green[50] : Colors.grey[50],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload,
                  color: hasFile ? Colors.green[600] : Colors.grey[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile ? 'File Selected' : 'Select Contact File',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasFile ? Colors.green[700] : Colors.grey[700],
                        ),
                      ),
                      Text(
                        hasFile ? label : 'Choose a CSV or Excel file with contacts',
                        style: TextStyle(
                          fontSize: 14,
                          color: hasFile ? Colors.green[600] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Show dialog to get header names
                  final headerNames = await _showHeaderDialog(context);
                  if (headerNames != null) {
                    List<Contact>? contacts = await FileService.pickContactsFile(
                      nameHeader: headerNames['nameHeader']!,
                      phoneHeader: headerNames['phoneHeader']!,
                    );
                    if (contacts != null) {
                      onFilePicked(contacts, "File selected successfully");
                    }
                  }
                },
                icon: const Icon(Icons.folder_open),
                label: Text(hasFile ? 'Change File' : 'Pick File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasFile ? Colors.green[600] : Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>?> _showHeaderDialog(BuildContext context) async {
    final nameController = TextEditingController(text: 'name');
    final phoneController = TextEditingController(text: 'phone');

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configure Column Headers'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Specify the column header names in your file:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name Column Header',
                    hintText: 'e.g., name, full_name, customer',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Column Header',
                    hintText: 'e.g., phone, number, mobile',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note: The search is case-insensitive and matches partial text.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final nameHeader = nameController.text.trim();
                final phoneHeader = phoneController.text.trim();

                if (nameHeader.isNotEmpty && phoneHeader.isNotEmpty) {
                  Navigator.of(context).pop({
                    'nameHeader': nameHeader,
                    'phoneHeader': phoneHeader,
                  });
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

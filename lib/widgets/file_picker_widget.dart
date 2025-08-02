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
                  List<Contact>? contacts = await FileService.pickContactsFile();
                  if (contacts != null) {
                    onFilePicked(contacts, "File selected successfully");
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
}

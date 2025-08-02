import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/contact.dart';

class FileService {
  static Future<List<Contact>?> pickContactsFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      List<dynamic> jsonData = jsonDecode(file.readAsStringSync());

      List<Contact> contacts = jsonData.map((json) => Contact.fromJson(json)).toList();

      return contacts;
    }
    return null;
  }
}

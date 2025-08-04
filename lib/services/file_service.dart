import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/contact.dart';

class FileService {
  static Future<List<Contact>?> pickContactsFile({
    String nameHeader = 'name',
    String phoneHeader = 'phone',
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv', 'xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name.toLowerCase();

      try {
        if (fileName.endsWith('.json')) {
          return _parseJsonFile(file);
        } else if (fileName.endsWith('.csv')) {
          return _parseCsvFile(file, nameHeader, phoneHeader);
        } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
          return _parseExcelFile(file, nameHeader, phoneHeader);
        } else {
          throw Exception('Unsupported file format');
        }
      } catch (e) {
        // Log error for debugging purposes
        // In production, consider using a proper logging framework
        // ignore: avoid_print
        print('Error parsing file: $e');
        return null;
      }
    }
    return null;
  }

  static List<Contact> _parseJsonFile(File file) {
    List<dynamic> jsonData = jsonDecode(file.readAsStringSync());
    return jsonData.map((json) => Contact.fromJson(json)).toList();
  }

  static List<Contact> _parseCsvFile(
      File file, String nameHeader, String phoneHeader) {
    String contents = file.readAsStringSync();
    List<List<dynamic>> csvData = const CsvToListConverter().convert(contents);

    List<Contact> contacts = [];

    if (csvData.isEmpty) return contacts;

    // Check if first row contains headers and find column indices
    Map<String, int> columnIndices = {};
    bool hasHeader = false;

    if (csvData[0].any((cell) =>
        cell.toString().toLowerCase().contains(nameHeader.toLowerCase()) ||
        cell.toString().toLowerCase().contains(phoneHeader.toLowerCase()))) {
      hasHeader = true;

      // Find the indices of name and phone columns
      for (int i = 0; i < csvData[0].length; i++) {
        String cellValue = csvData[0][i].toString().toLowerCase();
        if (cellValue.contains(nameHeader.toLowerCase())) {
          columnIndices['name'] = i;
        }
        if (cellValue.contains(phoneHeader.toLowerCase())) {
          columnIndices['phone'] = i;
        }
      }
    }

    int startRow = hasHeader ? 1 : 0;
    int nameIndex = columnIndices['name'] ?? 0;
    int phoneIndex = columnIndices['phone'] ?? 1;

    for (int i = startRow; i < csvData.length; i++) {
      List<dynamic> row = csvData[i];
      if (row.length > nameIndex && row.length > phoneIndex) {
        contacts.add(Contact(
          name: row[nameIndex].toString().trim(),
          phone: row[phoneIndex].toString().trim(),
        ));
      }
    }

    return contacts;
  }

  static List<Contact> _parseExcelFile(
      File file, String nameHeader, String phoneHeader) {
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<Contact> contacts = [];

    // Get the first sheet
    String? firstSheetName = excel.sheets.keys.first;
    Sheet? sheet = excel.sheets[firstSheetName];

    if (sheet != null) {
      List<List<Data?>> rows = sheet.rows;

      if (rows.isEmpty) return contacts;

      // Check if first row contains headers and find column indices
      Map<String, int> columnIndices = {};
      bool hasHeader = false;

      if (rows[0].length >= 2 &&
          rows[0].any((cell) =>
              cell?.value
                      .toString()
                      .toLowerCase()
                      .contains(nameHeader.toLowerCase()) ==
                  true ||
              cell?.value
                      .toString()
                      .toLowerCase()
                      .contains(phoneHeader.toLowerCase()) ==
                  true)) {
        hasHeader = true;

        // Find the indices of name and phone columns
        for (int i = 0; i < rows[0].length; i++) {
          String cellValue = rows[0][i]?.value.toString().toLowerCase() ?? '';
          if (cellValue.contains(nameHeader.toLowerCase())) {
            columnIndices['name'] = i;
          }
          if (cellValue.contains(phoneHeader.toLowerCase())) {
            columnIndices['phone'] = i;
          }
        }
      }

      int startRow = hasHeader ? 1 : 0;
      int nameIndex = columnIndices['name'] ?? 0;
      int phoneIndex = columnIndices['phone'] ?? 1;

      for (int i = startRow; i < rows.length; i++) {
        List<Data?> row = rows[i];
        if (row.length > nameIndex &&
            row.length > phoneIndex &&
            row[nameIndex]?.value != null &&
            row[phoneIndex]?.value != null) {
          contacts.add(Contact(
            name: row[nameIndex]!.value.toString().trim(),
            phone: row[phoneIndex]!.value.toString().trim(),
          ));
        }
      }
    }

    return contacts;
  }
}

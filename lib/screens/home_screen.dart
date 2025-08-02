import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/sms_service.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/contacts_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];
  List<Contact> sentContacts = [];
  String fileLabel = "No file selected";
  int counter = 0;

  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _onFilePicked(List<Contact> pickedContacts, String fileName) {
    setState(() {
      contacts = pickedContacts;
      fileLabel = fileName;
    });
  }

  void _clearData() {
    setState(() {
      sentContacts = [];
      counter = 0;
    });
  }

  Future<void> _sendMessages() async {
    if (contacts.isEmpty) {
      await _showErrorDialog("Please select a file");
      return;
    }

    for (var contact in contacts) {
      try {
        await SmsService.sendSms(
          message: messageController.text,
          number: contact.phone.trim(),
        );
        await Future.delayed(const Duration(seconds: 5));
        setState(() {
          sentContacts.add(contact);
          counter++;
        });
      } catch (e) {
        await _showErrorDialog("$e");
        break;
      }
    }

    await _showSuccessDialog("Message sent to $counter users");
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Message"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  counter = 0;
                });
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _clearData,
        child: const Text('Clear'),
      ),
      appBar: AppBar(
        title: const Text('Message sender app'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilePickerWidget(
              label: fileLabel,
              onFilePicked: _onFilePicked,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Message",
              ),
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              text: counter == 0 ? "Send" : "Sent $counter",
              onPressed: _sendMessages,
            ),
            ContactsListWidget(sentContacts: sentContacts),
          ],
        ),
      ),
    );
  }
}

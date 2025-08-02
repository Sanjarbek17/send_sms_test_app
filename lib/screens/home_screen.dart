import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/sms_service.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/contacts_list_widget.dart';
import '../widgets/phone_input_widget.dart';
import '../widgets/troubleshooting_dialog.dart';
import '../widgets/sim_card_selector.dart';
import '../widgets/permission_status_widget.dart';

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
  bool isSmsAvailable = true;
  int? selectedSimSlot;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSmsAvailability();
  }

  Future<void> _checkSmsAvailability() async {
    final available = await SmsService.checkSmsAvailability();
    setState(() {
      isSmsAvailable = available;
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    phoneController.dispose();
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
      phoneController.clear();
    });
  }

  Future<void> _sendTestMessage() async {
    if (phoneController.text.trim().isEmpty) {
      await _showErrorDialog("Please enter a phone number");
      return;
    }

    if (messageController.text.trim().isEmpty) {
      await _showErrorDialog("Please enter a message");
      return;
    }

    try {
      await SmsService.sendSms(
        message: messageController.text,
        number: phoneController.text.trim(),
        simSlot: selectedSimSlot,
      );
      await _showSuccessDialog("Test message sent successfully!");
    } catch (e) {
      await _showErrorDialog("Failed to send test message: $e");
    }
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
          simSlot: selectedSimSlot,
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
    bool isSimError = message.toLowerCase().contains('sim') || message.toLowerCase().contains('permission');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            if (isSimError)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _checkSmsAvailability();
                },
                child: const Text("Retry"),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => TroubleshootingDialog.show(context),
            tooltip: 'Troubleshooting Guide',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SMS availability warning
              if (!isSmsAvailable)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SMS Not Available',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const Text(
                              'Please check: 1) SIM card is inserted, 2) SMS permissions are granted, 3) Device supports SMS',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // File picker section
              FilePickerWidget(
                label: fileLabel,
                onFilePicked: _onFilePicked,
              ),
              const SizedBox(height: 16),

              // Test phone number section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Single Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PhoneInputWidget(
                        phoneController: phoneController,
                        label: "Test Phone Number",
                      ),
                      const SizedBox(height: 8),
                      CustomElevatedButton(
                        text: "Send Test Message",
                        onPressed: _sendTestMessage,
                        minWidth: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Permission Status
              PermissionStatusWidget(),
              const SizedBox(height: 16),

              // SIM Card Selection
              SimCardSelector(
                selectedSimSlot: selectedSimSlot,
                onSimSelected: (simSlot) {
                  setState(() {
                    selectedSimSlot = simSlot;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Message input
              TextFormField(
                controller: messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Message",
                ),
              ),
              const SizedBox(height: 16),

              // Bulk send button
              CustomElevatedButton(
                text: counter == 0 ? "Send to All Contacts" : "Sent $counter",
                onPressed: _sendMessages,
              ),
              ContactsListWidget(sentContacts: sentContacts),
            ],
          ),
        ),
      ),
    );
  }
}

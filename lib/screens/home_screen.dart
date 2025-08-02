import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/sms_service.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/contacts_list_widget.dart';
import '../widgets/phone_input_widget.dart';
import '../widgets/troubleshooting_dialog.dart';
import '../widgets/sim_card_selector.dart';
import '../widgets/permission_status_widget.dart';
import '../widgets/animated_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Contact> contacts = [];
  List<Contact> sentContacts = [];
  String fileLabel = "No file selected";
  int counter = 0;
  bool isSmsAvailable = true;
  bool isSending = false;
  int? selectedSimSlot;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _checkSmsAvailability();
    _animationController.forward();
  }

  Future<void> _checkSmsAvailability() async {
    final available = await SmsService.checkSmsAvailability();
    setState(() {
      isSmsAvailable = available;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      await _showErrorDialog("Please select a file with contacts");
      return;
    }

    if (messageController.text.trim().isEmpty) {
      await _showErrorDialog("Please enter a message to send");
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
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
          setState(() {
            isSending = false;
          });
          await _showErrorDialog("$e");
          break;
        }
      }

      setState(() {
        isSending = false;
      });
      await _showSuccessDialog("Messages sent successfully to $counter contacts!");
    } catch (e) {
      setState(() {
        isSending = false;
      });
      await _showErrorDialog("Failed to send messages: $e");
    }
  }

  Future<void> _showErrorDialog(String message) async {
    bool isSimError = message.toLowerCase().contains('sim') || message.toLowerCase().contains('permission');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text("Error"),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            if (isSimError)
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _checkSmsAvailability();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text("Success"),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  counter = 0;
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.message, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'SMS Sender Pro',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => TroubleshootingDialog.show(context),
            tooltip: 'Help & Troubleshooting',
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _clearData,
        icon: const Icon(Icons.clear_all),
        label: const Text('Clear All'),
        tooltip: 'Clear all data',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // SMS Status Card
                  AnimatedCard(
                    delay: 100,
                    child: _buildStatusCard(),
                  ),
                  const SizedBox(height: 16),

                  // File Selection Card
                  AnimatedCard(
                    delay: 200,
                    child: _buildFileSelectionCard(),
                  ),
                  const SizedBox(height: 16),

                  // Test Message Card
                  AnimatedCard(
                    delay: 300,
                    child: _buildTestMessageCard(),
                  ),
                  const SizedBox(height: 16),

                  // Settings Card
                  AnimatedCard(
                    delay: 400,
                    child: _buildSettingsCard(),
                  ),
                  const SizedBox(height: 16),

                  // Message Input Card
                  AnimatedCard(
                    delay: 500,
                    child: _buildMessageInputCard(),
                  ),
                  const SizedBox(height: 16),

                  // Send Button Card
                  AnimatedCard(
                    delay: 600,
                    child: _buildSendButtonCard(),
                  ),
                  const SizedBox(height: 16),

                  // Progress and Contacts List
                  if (sentContacts.isNotEmpty || isSending)
                    AnimatedCard(
                      delay: 700,
                      child: _buildProgressCard(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isSmsAvailable ? Icons.check_circle : Icons.error,
                  color: isSmsAvailable ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSmsAvailable ? 'SMS Ready' : 'SMS Not Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSmsAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        isSmsAvailable ? 'Your device is ready to send SMS messages' : 'Please check SIM card, permissions, and device SMS support',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isSmsAvailable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkSmsAvailability,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Check'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Select Contact File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilePickerWidget(
              label: fileLabel,
              onFilePicked: _onFilePicked,
            ),
            if (contacts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.contacts, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      '${contacts.length} contacts loaded',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestMessageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone_android, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Test Single Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PhoneInputWidget(
              phoneController: phoneController,
              label: "Test Phone Number",
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendTestMessage,
                icon: const Icon(Icons.send),
                label: const Text('Send Test Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PermissionStatusWidget(),
            const SizedBox(height: 16),
            SimCardSelector(
              selectedSimSlot: selectedSimSlot,
              onSimSelected: (simSlot) {
                setState(() {
                  selectedSimSlot = simSlot;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Message Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Enter your message",
                hintText: "Type the message you want to send to all contacts...",
                prefixIcon: const Icon(Icons.edit),
                suffixText: '${messageController.text.length}/160',
              ),
              onChanged: (value) {
                setState(() {}); // To update character count
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButtonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: isSending ? null : _sendMessages,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 24),
                label: Text(
                  isSending
                      ? 'Sending... ($counter/${contacts.length})'
                      : counter == 0
                          ? "Send to All Contacts (${contacts.length})"
                          : "Sent to $counter contacts",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSending ? Colors.grey : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select a contact file first',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Sending Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (contacts.isNotEmpty) ...[
              LinearProgressIndicator(
                value: counter / contacts.length,
                backgroundColor: Colors.grey[300],
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '$counter of ${contacts.length} messages sent',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (sentContacts.isNotEmpty) ContactsListWidget(sentContacts: sentContacts),
          ],
        ),
      ),
    );
  }
}

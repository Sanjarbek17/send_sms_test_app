import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/contacts_list_widget.dart';
import '../widgets/animated_card.dart';
import '../models/contact.dart';
import '../generated/l10n/app_localizations.dart';

class BulkSmsScreen extends StatefulWidget {
  final int? selectedSimSlot;

  const BulkSmsScreen({
    Key? key,
    required this.selectedSimSlot,
  }) : super(key: key);

  @override
  State<BulkSmsScreen> createState() => _BulkSmsScreenState();
}

class _BulkSmsScreenState extends State<BulkSmsScreen> {
  List<Contact> contacts = [];
  List<Contact> sentContacts = [];
  String? fileLabel; // Will be set to localized text when needed
  int counter = 0;
  bool isSending = false;

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
      sentContacts.clear();
      counter = 0;
    });
  }

  Future<void> _sendMessages() async {
    if (contacts.isEmpty) {
      await _showErrorDialog(AppLocalizations.of(context).pleaseSelectFile);
      return;
    }

    if (messageController.text.trim().isEmpty) {
      await _showErrorDialog(
          AppLocalizations.of(context).pleaseEnterMessageToSend);
      return;
    }

    setState(() {
      isSending = true;
      sentContacts.clear();
      counter = 0;
    });

    try {
      for (var contact in contacts) {
        try {
          await SmsService.sendSms(
            message: messageController.text,
            number: contact.phone.trim(),
            simSlot: widget.selectedSimSlot,
          );
          await Future.delayed(
              const Duration(seconds: 2)); // Reduced delay for demo
          setState(() {
            sentContacts.add(contact);
            counter++;
          });
        } catch (e) {
          setState(() {
            isSending = false;
          });
          await _showErrorDialog("Failed to send to ${contact.name}: $e");
          break;
        }
      }

      setState(() {
        isSending = false;
      });
      await _showSuccessDialog(
          AppLocalizations.of(context).messagesSentSuccessfully(counter));
    } catch (e) {
      setState(() {
        isSending = false;
      });
      await _showErrorDialog(
          AppLocalizations.of(context).failedToSendMessages(e.toString()));
    }
  }

  Future<void> _showErrorDialog(String message) async {
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
              Text(AppLocalizations.of(context).error),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).ok),
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
              Text(AppLocalizations.of(context).success),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check),
              label: Text(AppLocalizations.of(context).ok),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // File Selection Card
              AnimatedCard(
                delay: 100,
                child: _buildFileSelectionCard(),
              ),
              const SizedBox(height: 16),

              // Message Input Card
              AnimatedCard(
                delay: 200,
                child: _buildMessageInputCard(),
              ),
              const SizedBox(height: 16),

              // Send Button Card
              AnimatedCard(
                delay: 300,
                child: _buildSendButtonCard(),
              ),
              const SizedBox(height: 16),

              // Progress Card
              if (sentContacts.isNotEmpty || isSending)
                AnimatedCard(
                  delay: 400,
                  child: _buildProgressCard(),
                ),
            ],
          ),
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
                Text(
                  AppLocalizations.of(context).selectContactFile,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilePickerWidget(
              label: fileLabel ?? AppLocalizations.of(context).noFileSelected,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${contacts.length} ${AppLocalizations.of(context).contactsLoaded}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).readyToSendBulk,
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
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
                Text(
                  AppLocalizations.of(context).messageContent,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: messageController,
              maxLines: 6,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context).enterYourMessage,
                hintText: AppLocalizations.of(context).messageHint,
                prefixIcon: const Icon(Icons.edit),
                suffixText: '${messageController.text.length}/160',
                helperText: AppLocalizations.of(context).helperText,
              ),
              onChanged: (value) {
                setState(() {}); // To update character count
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        sentContacts = [];
                        counter = 0;
                        contacts = [];
                        fileLabel = AppLocalizations.of(context).noFileSelected;
                        messageController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: Text(AppLocalizations.of(context).clearAllData),
                  ),
                ),
              ],
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
                onPressed: (isSending ||
                        contacts.isEmpty ||
                        messageController.text.trim().isEmpty)
                    ? null
                    : _sendMessages,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 24),
                label: Text(
                  isSending
                      ? '${AppLocalizations.of(context).sending} ($counter/${contacts.length})'
                      : "${AppLocalizations.of(context).sendToAllContacts} (${contacts.length})",
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
            const SizedBox(height: 8),
            if (contacts.isEmpty)
              Text(
                AppLocalizations.of(context).pleaseSelectFile,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              )
            else if (messageController.text.trim().isEmpty)
              Text(
                AppLocalizations.of(context).pleaseEnterMessageToSend,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              )
            else
              Text(
                AppLocalizations.of(context)
                    .readyToSendToContacts(contacts.length),
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                Text(
                  AppLocalizations.of(context).sendingProgress,
                  style: const TextStyle(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)
                        .messagesSent(counter, contacts.length),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${((counter / contacts.length) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (sentContacts.isNotEmpty)
              ContactsListWidget(sentContacts: sentContacts),
          ],
        ),
      ),
    );
  }
}

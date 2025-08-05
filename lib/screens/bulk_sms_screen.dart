import 'package:flutter/material.dart';
import '../services/custom_sms_service.dart';
import '../services/settings_service.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/contacts_list_widget.dart';
import '../widgets/animated_card.dart';
import '../models/contact.dart';
import '../generated/l10n/app_localizations.dart';
import 'dart:async';

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
  List<Contact> skippedContacts = [];
  String? fileLabel; // Will be set to localized text when needed
  int counter = 0;
  int sentCounter = 0;
  int skippedCounter = 0;
  bool isSending = false;
  String currentSendingStatus = ''; // Track current SMS status
  String currentContactName = ''; // Track current contact being processed
  StreamSubscription<SmsStatusUpdate>? _statusSubscription;

  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupStatusListener();
  }

  void _setupStatusListener() {
    try {
      _statusSubscription = CustomSmsService.statusStream.listen(
        (statusUpdate) {
          if (mounted) {
            setState(() {
              // Update current status based on the stream
              currentSendingStatus = 'Status: ${statusUpdate.status.statusName}';
            });
            print('Real-time status: ${statusUpdate.status.statusName}');
          }
        },
        onError: (error) {
          print('Status stream error: $error');
        },
      );
    } catch (e) {
      print('Failed to setup status listener: $e');
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    messageController.dispose();
    super.dispose();
  }

  void _onFilePicked(List<Contact> pickedContacts, String fileName) {
    setState(() {
      contacts = pickedContacts;
      fileLabel = fileName;
      sentContacts.clear();
      skippedContacts.clear();
      counter = 0;
      sentCounter = 0;
      skippedCounter = 0;
      currentSendingStatus = '';
      currentContactName = '';
    });
  }

  Future<void> _sendMessages() async {
    if (contacts.isEmpty) {
      await _showErrorDialog(AppLocalizations.of(context).pleaseSelectFile);
      return;
    }

    if (messageController.text.trim().isEmpty) {
      await _showErrorDialog(AppLocalizations.of(context).pleaseEnterMessageToSend);
      return;
    }

    setState(() {
      isSending = true;
      sentContacts.clear();
      skippedContacts.clear();
      counter = 0;
      sentCounter = 0;
      skippedCounter = 0;
      currentSendingStatus = 'Initializing...';
      currentContactName = '';
    });

    try {
      for (var contact in contacts) {
        setState(() {
          currentContactName = contact.name;
          currentSendingStatus = 'Preparing to send...';
        });

        try {
          // Debug logging
          print('Attempting to send SMS to: ${contact.name} (${contact.phone.trim()})');
          print('Message length: ${messageController.text.length}');
          print('SIM slot: ${widget.selectedSimSlot}');

          // Validate phone number and message before sending
          if (contact.phone.trim().isEmpty) {
            print("Skipping contact ${contact.name} - empty phone number");
            // Add to skipped contacts instead of sent contacts
            setState(() {
              skippedContacts.add(contact);
              skippedCounter++;
              counter++;
              currentSendingStatus = 'Skipped - No phone number';
            });
            
            // Brief pause to show status, then continue without long delay for skipped contacts
            await Future.delayed(Duration(milliseconds: 300));
            continue; // Skip this contact instead of throwing an error
          }

          if (messageController.text.trim().isEmpty) {
            throw Exception("Message is empty");
          }

          setState(() {
            currentSendingStatus = 'Sending SMS...';
          });

          // Send SMS with enhanced status tracking - waits for actual sent confirmation
          final smsResult = await CustomSmsService.sendSmsWithTracking(
            message: messageController.text,
            number: contact.phone.trim(),
            simSlot: widget.selectedSimSlot,
          );

          if (smsResult.success) {
            print('SMS ${smsResult.type.toString().split('.').last} to ${contact.name}: ${smsResult.message}');
            setState(() {
              sentContacts.add(contact);
              sentCounter++;
              counter++;
              currentSendingStatus = 'Successfully sent!';
            });
            
            // Get configured delay settings - user can set to 0 for no delay
            final delaySeconds = await SettingsService.instance.getSmsDelaySeconds();
            
            if (delaySeconds > 0) {
              // Show countdown only if there's actually a delay
              setState(() {
                currentSendingStatus = 'Waiting ${delaySeconds}s before next SMS...';
              });
              
              await Future.delayed(Duration(seconds: delaySeconds));
            } else {
              // No delay - just a brief pause to show "Successfully sent!" status
              await Future.delayed(Duration(milliseconds: 200));
            }
          } else {
            throw Exception(smsResult.message);
          }
        } catch (e) {
          print('Error sending SMS to ${contact.name}: $e');
          setState(() {
            skippedContacts.add(contact);
            skippedCounter++;
            counter++;
            currentSendingStatus = 'Failed - $e';
          });
          
          // Show a dialog asking if user wants to continue or stop
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('SMS Failed'),
                content: Text('Failed to send SMS to ${contact.name}:\n\n$e\n\nDo you want to continue with remaining contacts?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Stop'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Continue'),
                  ),
                ],
              );
            },
          );
          
          if (shouldContinue != true) {
            setState(() {
              isSending = false;
            });
            break;
          }
          
          // Brief delay before continuing
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      setState(() {
        isSending = false;
      });
      await _showSuccessDialog("${AppLocalizations.of(context).messagesSentSuccessfully(sentCounter)}${skippedCounter > 0 ? '\n$skippedCounter contacts were skipped due to missing phone numbers.' : ''}");
    } catch (e) {
      setState(() {
        isSending = false;
      });
      await _showErrorDialog(AppLocalizations.of(context).failedToSendMessages(e.toString()));
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
              if (sentContacts.isNotEmpty || skippedContacts.isNotEmpty || isSending)
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

            // Add test contact button for debugging
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  contacts = [
                    Contact(name: "Test Contact 1", phone: "+998901234567"),
                    Contact(name: "Test Contact 2", phone: "+998901234568"),
                    Contact(name: "Test Contact 3", phone: "+998901234569"),
                    Contact(name: "Empty Phone Test", phone: ""), // Test empty phone
                    Contact(name: "Same Number Test", phone: "+998901234567"), // Same as first for testing
                  ];
                  fileLabel = "Test contacts (5 contacts, 1 with empty phone)";
                  sentContacts.clear();
                  skippedContacts.clear();
                  counter = 0;
                  sentCounter = 0;
                  skippedCounter = 0;
                  currentSendingStatus = '';
                  currentContactName = '';
                });
              },
              icon: const Icon(Icons.bug_report),
              label: const Text("Add Test Contacts"),
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
                        skippedContacts = [];
                        counter = 0;
                        sentCounter = 0;
                        skippedCounter = 0;
                        contacts = [];
                        fileLabel = AppLocalizations.of(context).noFileSelected;
                        messageController.clear();
                        currentSendingStatus = '';
                        currentContactName = '';
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
                onPressed: (isSending || contacts.isEmpty || messageController.text.trim().isEmpty) ? null : _sendMessages,
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
                  isSending ? '${AppLocalizations.of(context).sending} ($counter/${contacts.length})\n${currentContactName.isNotEmpty ? '$currentContactName: $currentSendingStatus' : currentSendingStatus}' : "${AppLocalizations.of(context).sendToAllContacts} (${contacts.length})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
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
                AppLocalizations.of(context).readyToSendToContacts(contacts.length),
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
                    'Processed: $counter/${contacts.length}',
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
              const SizedBox(height: 12),

              // Detailed statistics
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                          const SizedBox(height: 4),
                          Text(
                            '$sentCounter',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Sent',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.skip_next, color: Colors.orange[600], size: 20),
                          const SizedBox(height: 4),
                          Text(
                            '$skippedCounter',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Skipped',
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pending, color: Colors.grey[600], size: 20),
                          const SizedBox(height: 4),
                          Text(
                            '${contacts.length - counter}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Pending',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Show sent contacts
            if (sentContacts.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Successfully Sent ($sentCounter)',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ContactsListWidget(sentContacts: sentContacts),
                  ],
                ),
              ),
            ],

            // Show skipped contacts
            if (skippedContacts.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.skip_next, color: Colors.orange[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Skipped Contacts ($skippedCounter)',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ContactsListWidget(sentContacts: skippedContacts),
                    const SizedBox(height: 4),
                    Text(
                      'Reason: Missing phone numbers',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
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
}

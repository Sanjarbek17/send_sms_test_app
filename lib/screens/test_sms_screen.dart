import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import '../widgets/phone_input_widget.dart';
import '../widgets/animated_card.dart';
import '../generated/l10n/app_localizations.dart';

class TestSmsScreen extends StatefulWidget {
  final int? selectedSimSlot;

  const TestSmsScreen({
    Key? key,
    required this.selectedSimSlot,
  }) : super(key: key);

  @override
  State<TestSmsScreen> createState() => _TestSmsScreenState();
}

class _TestSmsScreenState extends State<TestSmsScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool isSending = false;

  @override
  void dispose() {
    phoneController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _sendTestMessage() async {
    if (phoneController.text.trim().isEmpty) {
      await _showErrorDialog(AppLocalizations.of(context).pleaseEnterPhoneNumber);
      return;
    }

    if (messageController.text.trim().isEmpty) {
      await _showErrorDialog(AppLocalizations.of(context).pleaseEnterMessage);
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await SmsService.sendSms(
        message: messageController.text,
        number: phoneController.text.trim(),
        simSlot: widget.selectedSimSlot,
      );
      await _showSuccessDialog(AppLocalizations.of(context).testMessageSentSuccessfully);
    } catch (e) {
      await _showErrorDialog(AppLocalizations.of(context).failedToSendTestMessage(e.toString()));
    } finally {
      setState(() {
        isSending = false;
      });
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
              // Info Card
              AnimatedCard(
                delay: 100,
                child: _buildInfoCard(),
              ),
              const SizedBox(height: 16),

              // Phone Input Card
              AnimatedCard(
                delay: 200,
                child: _buildPhoneInputCard(),
              ),
              const SizedBox(height: 16),

              // Message Input Card
              AnimatedCard(
                delay: 300,
                child: _buildMessageInputCard(),
              ),
              const SizedBox(height: 16),

              // Send Button Card
              AnimatedCard(
                delay: 400,
                child: _buildSendButtonCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).testSMSFunctionality,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).testSMSDescription,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Test with your own number first',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        phoneController.clear();
                        messageController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: Text(AppLocalizations.of(context).clearAll),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Phone Number',
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
              label: AppLocalizations.of(context).testPhoneNumber,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the phone number you want to test with (including country code)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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
                  'Test Message',
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
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Enter test message",
                hintText: AppLocalizations.of(context).testMessageHint,
                prefixIcon: const Icon(Icons.edit),
                suffixText: '${messageController.text.length}/160',
              ),
              onChanged: (value) {
                setState(() {}); // To update character count
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Write a short test message to verify SMS functionality',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButtonCard() {
    bool canSend = phoneController.text.trim().isNotEmpty && messageController.text.trim().isNotEmpty && !isSending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: canSend ? _sendTestMessage : null,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, size: 24),
                label: Text(
                  isSending ? 'Sending Test...' : 'Send Test Message',
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
            if (!canSend && !isSending)
              Text(
                phoneController.text.trim().isEmpty ? 'Please enter a phone number' : 'Please enter a test message',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              )
            else if (canSend)
              Text(
                'Ready to send test message',
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
}

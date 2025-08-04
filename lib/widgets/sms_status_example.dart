import 'package:flutter/material.dart';
import '../services/enhanced_sms_service.dart';
import '../services/sms_status_service.dart';

class SmsStatusExample extends StatefulWidget {
  const SmsStatusExample({Key? key}) : super(key: key);

  @override
  _SmsStatusExampleState createState() => _SmsStatusExampleState();
}

class _SmsStatusExampleState extends State<SmsStatusExample> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _status = 'Ready to send';
  bool _isSending = false;
  final List<String> _statusHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    await EnhancedSmsService.initialize();

    // Listen to status updates for real-time feedback
    SmsStatusService.statusStream.listen((statusUpdate) {
      setState(() {
        _statusHistory.add('${DateTime.now().toString().substring(11, 19)}: '
            '${statusUpdate.phoneNumber} - ${statusUpdate.status.statusName}'
            '${statusUpdate.errorMessage != null ? ' (${statusUpdate.errorMessage})' : ''}');
      });
    });
  }

  Future<void> _sendSms() async {
    if (_phoneController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      _showSnackBar('Please enter both phone number and message', isError: true);
      return;
    }

    setState(() {
      _isSending = true;
      _status = 'Sending SMS...';
      _statusHistory.clear();
    });

    try {
      final result = await EnhancedSmsService.sendSmsWithTracking(
        number: _phoneController.text.trim(),
        message: _messageController.text.trim(),
        timeout: Duration(seconds: 30),
      );

      setState(() {
        _isSending = false;
        if (result.success) {
          _status = result.message;
          _showSnackBar(result.message, isError: false);
        } else {
          _status = 'Failed: ${result.message}';
          _showSnackBar(result.message, isError: true);
        }
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _status = 'Error: $e';
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMS Status Tracking'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone number input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+998901234567',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            // Message input
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your message here',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Send button
            ElevatedButton(
              onPressed: _isSending ? null : _sendSms,
              child: _isSending
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Sending...'),
                      ],
                    )
                  : Text('Send SMS'),
            ),
            SizedBox(height: 16),

            // Status display
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 14,
                      color: _status.startsWith('Failed') || _status.startsWith('Error') ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Status history
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status History:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _statusHistory.isEmpty
                          ? Center(
                              child: Text(
                                'No status updates yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _statusHistory.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    _statusHistory[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TroubleshootingDialog extends StatelessWidget {
  const TroubleshootingDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const TroubleshootingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SMS Troubleshooting'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'If you\'re having trouble sending SMS:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTroubleshootingItem(
              '1. SIM Card',
              'Make sure your device has an active SIM card inserted and it\'s properly recognized.',
            ),
            _buildTroubleshootingItem(
              '2. Permissions',
              'Grant SMS permissions to this app in your device settings.',
            ),
            _buildTroubleshootingItem(
              '3. Network',
              'Ensure you have cellular network coverage.',
            ),
            _buildTroubleshootingItem(
              '4. Phone Number',
              'Verify the phone number format is correct (include country code if needed).',
            ),
            _buildTroubleshootingItem(
              '5. Device Support',
              'Some emulators or devices may not support SMS functionality.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Common Error Codes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildErrorCode('NO_SIM', 'No active SIM card detected'),
            _buildErrorCode('PERMISSION_DENIED', 'SMS permission not granted'),
            _buildErrorCode('NETWORK_ERROR', 'Network connectivity issue'),
            _buildErrorCode('INVALID_NUMBER', 'Phone number format error'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCode(String code, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          const Text(': '),
          Expanded(child: Text(description, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }
}

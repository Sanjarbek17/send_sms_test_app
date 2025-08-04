import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

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
      title: Text(AppLocalizations.of(context).smsTroubleshooting),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).troubleshootingIntro,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTroubleshootingItem(
              AppLocalizations.of(context).troubleshootingSimCard,
              AppLocalizations.of(context).troubleshootingSimCardDesc,
            ),
            _buildTroubleshootingItem(
              AppLocalizations.of(context).troubleshootingPermissions,
              AppLocalizations.of(context).troubleshootingPermissionsDesc,
            ),
            _buildTroubleshootingItem(
              AppLocalizations.of(context).troubleshootingNetwork,
              AppLocalizations.of(context).troubleshootingNetworkDesc,
            ),
            _buildTroubleshootingItem(
              AppLocalizations.of(context).troubleshootingPhoneNumber,
              AppLocalizations.of(context).troubleshootingPhoneNumberDesc,
            ),
            _buildTroubleshootingItem(
              AppLocalizations.of(context).troubleshootingDeviceSupport,
              AppLocalizations.of(context).troubleshootingDeviceSupportDesc,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).commonErrorCodes,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildErrorCode(AppLocalizations.of(context).errorNoSim, AppLocalizations.of(context).errorNoSimDesc),
            _buildErrorCode(AppLocalizations.of(context).errorPermissionDenied, AppLocalizations.of(context).errorPermissionDeniedDesc),
            _buildErrorCode(AppLocalizations.of(context).errorNetworkError, AppLocalizations.of(context).errorNetworkErrorDesc),
            _buildErrorCode(AppLocalizations.of(context).errorInvalidNumber, AppLocalizations.of(context).errorInvalidNumberDesc),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).close),
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

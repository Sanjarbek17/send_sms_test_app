import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

class PermissionService {
  /// Check if all required SMS permissions are granted
  static Future<bool> hasAllSmsPermissions() async {
    final smsPermission = await Permission.sms.status;
    final phonePermission = await Permission.phone.status;

    return smsPermission.isGranted && phonePermission.isGranted;
  }

  /// Request all necessary SMS permissions
  static Future<Map<Permission, PermissionStatus>> requestSmsPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.sms,
      Permission.phone,
    ].request();

    return permissions;
  }

  /// Get detailed permission status
  static Future<Map<String, PermissionStatus>> getDetailedPermissionStatus() async {
    return {
      'SMS': await Permission.sms.status,
      'Phone': await Permission.phone.status,
    };
  }

  /// Check individual permission status
  static Future<PermissionStatus> getSmsPermissionStatus() async {
    return await Permission.sms.status;
  }

  static Future<PermissionStatus> getPhonePermissionStatus() async {
    return await Permission.phone.status;
  }

  /// Show permission explanation dialog
  static Future<void> showPermissionExplanationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).permissionsRequired),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).permissionExplanation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _PermissionItem(
              icon: Icons.sms,
              title: AppLocalizations.of(context).smsPermission,
              description: AppLocalizations.of(context).smsPermissionDesc,
            ),
            const SizedBox(height: 8),
            _PermissionItem(
              icon: Icons.sim_card,
              title: AppLocalizations.of(context).phoneStatePermission,
              description: AppLocalizations.of(context).phoneStatePermissionDesc,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).privacyNote,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }

  /// Open app settings for manual permission grant
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

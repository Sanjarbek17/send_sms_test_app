import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../generated/l10n/app_localizations.dart';

class PermissionStatusWidget extends StatefulWidget {
  const PermissionStatusWidget({Key? key}) : super(key: key);

  @override
  State<PermissionStatusWidget> createState() => _PermissionStatusWidgetState();
}

class _PermissionStatusWidgetState extends State<PermissionStatusWidget> {
  Map<String, PermissionStatus> permissions = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final perms = await PermissionService.getDetailedPermissionStatus();
    setState(() {
      permissions = perms;
      isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() {
      isLoading = true;
    });

    await PermissionService.requestSmsPermissions();
    await _loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).checkingPermissions),
            ],
          ),
        ),
      );
    }

    bool allGranted = permissions.values.every((status) => status.isGranted);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allGranted ? Icons.check_circle : Icons.warning,
                  color: allGranted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).permissionStatus,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...permissions.entries.map((entry) => _buildPermissionRow(entry.key, entry.value)),
            if (!allGranted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _requestPermissions,
                      icon: const Icon(Icons.security),
                      label: Text(AppLocalizations.of(context).requestPermissions),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => PermissionService.showPermissionExplanationDialog(context),
                    icon: const Icon(Icons.info_outline),
                    tooltip: AppLocalizations.of(context).whyThesePermissions,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String name, PermissionStatus status) {
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case PermissionStatus.granted:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = AppLocalizations.of(context).granted;
        break;
      case PermissionStatus.denied:
        icon = Icons.cancel;
        color = Colors.red;
        statusText = AppLocalizations.of(context).denied;
        break;
      case PermissionStatus.permanentlyDenied:
        icon = Icons.block;
        color = Colors.red;
        statusText = AppLocalizations.of(context).permanentlyDenied;
        break;
      case PermissionStatus.restricted:
        icon = Icons.warning;
        color = Colors.orange;
        statusText = AppLocalizations.of(context).restricted;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
        statusText = AppLocalizations.of(context).unknown;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(name)),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

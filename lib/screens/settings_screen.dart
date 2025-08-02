import 'package:flutter/material.dart';
import '../widgets/permission_status_widget.dart';
import '../widgets/sim_card_selector.dart';
import '../widgets/animated_card.dart';
import '../widgets/troubleshooting_dialog.dart';
import '../services/sms_service.dart';

class SettingsScreen extends StatefulWidget {
  final int? selectedSimSlot;
  final Function(int?) onSimSelected;

  const SettingsScreen({
    Key? key,
    required this.selectedSimSlot,
    required this.onSimSelected,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSmsAvailable = true;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Settings',
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
      body: Container(
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
                  child: _buildSmsStatusCard(),
                ),
                const SizedBox(height: 16),

                // Permission Status Card
                AnimatedCard(
                  delay: 200,
                  child: _buildPermissionCard(),
                ),
                const SizedBox(height: 16),

                // SIM Card Selection Card
                AnimatedCard(
                  delay: 300,
                  child: _buildSimCardCard(),
                ),
                const SizedBox(height: 16),

                // App Information Card
                AnimatedCard(
                  delay: 400,
                  child: _buildAppInfoCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmsStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sms, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'SMS Service Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                          fontSize: 16,
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

  Widget _buildPermissionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Permissions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PermissionStatusWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimCardCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sim_card, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'SIM Card Selection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SimCardSelector(
              selectedSimSlot: widget.selectedSimSlot,
              onSimSelected: widget.onSimSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'App Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.app_settings_alt, 'Version', '1.0.0'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.developer_mode, 'Developer', 'SMS Sender Pro Team'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.android, 'Platform', 'Android & iOS'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => TroubleshootingDialog.show(context),
                icon: const Icon(Icons.help_outline),
                label: const Text('Troubleshooting Guide'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

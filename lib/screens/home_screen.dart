import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import '../widgets/animated_card.dart';
import '../widgets/troubleshooting_dialog.dart';
import 'settings_screen.dart';
import 'bulk_sms_screen.dart';
import 'test_sms_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isSmsAvailable = true;
  int? selectedSimSlot;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    super.dispose();
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
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
                  // Welcome Card
                  AnimatedCard(
                    delay: 100,
                    child: _buildWelcomeCard(),
                  ),
                  const SizedBox(height: 20),

                  // SMS Status Card
                  AnimatedCard(
                    delay: 200,
                    child: _buildStatusCard(),
                  ),
                  const SizedBox(height: 20),

                  // Quick Actions Grid
                  AnimatedCard(
                    delay: 300,
                    child: _buildQuickActionsCard(),
                  ),
                  const SizedBox(height: 20),

                  // Features Overview Card
                  AnimatedCard(
                    delay: 400,
                    child: _buildFeaturesCard(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.waving_hand,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to SMS Sender Pro!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your professional SMS broadcasting solution. Send messages to multiple contacts with ease.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSmsAvailable ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                isSmsAvailable ? Icons.check_circle : Icons.error,
                color: isSmsAvailable ? Colors.green[700] : Colors.red[700],
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSmsAvailable ? 'SMS Service Ready' : 'SMS Service Unavailable',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSmsAvailable ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                  Text(
                    isSmsAvailable ? 'Your device is ready to send SMS messages' : 'Please check your SIM card and permissions',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (!isSmsAvailable)
              IconButton(
                onPressed: _checkSmsAvailability,
                icon: Icon(Icons.refresh, color: Colors.orange[700]),
                tooltip: 'Retry Check',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildActionButton(
                  icon: Icons.phone_android,
                  title: 'Test SMS',
                  subtitle: 'Send test message',
                  color: Colors.green,
                  onTap: () => _navigateToScreen(TestSmsScreen(selectedSimSlot: selectedSimSlot)),
                ),
                _buildActionButton(
                  icon: Icons.group,
                  title: 'Bulk SMS',
                  subtitle: 'Send to multiple contacts',
                  color: Colors.blue,
                  onTap: () => _navigateToScreen(BulkSmsScreen(selectedSimSlot: selectedSimSlot)),
                ),
                _buildActionButton(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Configure app settings',
                  color: Colors.orange,
                  onTap: () => _navigateToScreen(SettingsScreen(
                    selectedSimSlot: selectedSimSlot,
                    onSimSelected: (simSlot) {
                      setState(() {
                        selectedSimSlot = simSlot;
                      });
                    },
                  )),
                ),
                _buildActionButton(
                  icon: Icons.help_outline,
                  title: 'Help',
                  subtitle: 'Troubleshooting guide',
                  color: Colors.purple,
                  onTap: () => TroubleshootingDialog.show(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color[700],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.speed,
              'Bulk Messaging',
              'Send SMS to multiple contacts from CSV/Excel files',
            ),
            _buildFeatureItem(
              Icons.security,
              'Secure & Private',
              'All messages are sent directly from your device',
            ),
            _buildFeatureItem(
              Icons.sim_card,
              'Dual SIM Support',
              'Choose which SIM card to use for sending',
            ),
            _buildFeatureItem(
              Icons.analytics,
              'Progress Tracking',
              'Real-time progress monitoring during bulk sends',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
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
    );
  }
}

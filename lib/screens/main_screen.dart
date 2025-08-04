import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import '../widgets/animated_card.dart';
import '../widgets/troubleshooting_dialog.dart';
import '../generated/l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'bulk_sms_screen.dart';
import 'test_sms_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _screens => [
        _buildHomeTab(),
        TestSmsScreen(selectedSimSlot: selectedSimSlot),
        BulkSmsScreen(selectedSimSlot: selectedSimSlot),
        SettingsScreen(
          selectedSimSlot: selectedSimSlot,
          onSimSelected: (simSlot) {
            setState(() {
              selectedSimSlot = simSlot;
            });
          },
        ),
      ];

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
            Text(
              _getAppBarTitle(),
              style: const TextStyle(
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              activeIcon: const Icon(Icons.home_rounded),
              label: AppLocalizations.of(context).home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.phone_android),
              activeIcon: const Icon(Icons.phone_android_rounded),
              label: AppLocalizations.of(context).testSMS,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group),
              activeIcon: const Icon(Icons.group_rounded),
              label: AppLocalizations.of(context).bulkSMS,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              activeIcon: const Icon(Icons.settings_rounded),
              label: AppLocalizations.of(context).settings,
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return l10n.appTitle;
      case 1:
        return l10n.testSMS;
      case 2:
        return l10n.bulkSMS;
      case 3:
        return l10n.settings;
      default:
        return l10n.appTitle;
    }
  }

  Widget _buildHomeTab() {
    return FadeTransition(
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

                // Quick Stats Card
                AnimatedCard(
                  delay: 300,
                  child: _buildQuickStatsCard(),
                ),
              ],
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
            Text(
              AppLocalizations.of(context).welcome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).welcomeDescription,
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
                    isSmsAvailable ? AppLocalizations.of(context).smsServiceReady : AppLocalizations.of(context).smsServiceUnavailable,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSmsAvailable ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                  Text(
                    isSmsAvailable ? AppLocalizations.of(context).deviceReady : AppLocalizations.of(context).checkSimCard,
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
                tooltip: AppLocalizations.of(context).retryCheck,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
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
                  AppLocalizations.of(context).quickActions,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessItem(
                    Icons.phone_android,
                    AppLocalizations.of(context).testSMS,
                    AppLocalizations.of(context).sendTestMessage,
                    Colors.green,
                    () => setState(() => _selectedIndex = 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessItem(
                    Icons.group,
                    AppLocalizations.of(context).bulkSMS,
                    AppLocalizations.of(context).sendToMultipleContacts,
                    Colors.blue,
                    () => setState(() => _selectedIndex = 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessItem(
                    Icons.settings,
                    AppLocalizations.of(context).settings,
                    AppLocalizations.of(context).configureAppSettings,
                    Colors.orange,
                    () => setState(() => _selectedIndex = 3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessItem(
                    Icons.help_outline,
                    AppLocalizations.of(context).help,
                    AppLocalizations.of(context).troubleshootingGuide,
                    Colors.purple,
                    () => TroubleshootingDialog.show(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem(
    IconData icon,
    String title,
    String subtitle,
    MaterialColor color,
    VoidCallback onTap,
  ) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
            children: [
              Icon(
                icon,
                size: 24,
                color: color[700],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

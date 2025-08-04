import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../generated/l10n/app_localizations.dart';

class DelaySettingsWidget extends StatefulWidget {
  final Function()? onDelayChanged;

  const DelaySettingsWidget({
    Key? key,
    this.onDelayChanged,
  }) : super(key: key);

  @override
  State<DelaySettingsWidget> createState() => _DelaySettingsWidgetState();
}

class _DelaySettingsWidgetState extends State<DelaySettingsWidget> {
  int _currentDelay = SettingsService.defaultDelaySeconds;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentDelay();
  }

  Future<void> _loadCurrentDelay() async {
    final delay = await SettingsService.instance.getSmsDelaySeconds();
    setState(() {
      _currentDelay = delay;
      _isLoading = false;
    });
  }

  Future<void> _updateDelay(int newDelay) async {
    if (!SettingsService.isValidDelay(newDelay)) {
      _showErrorSnackBar(AppLocalizations.of(context).delayRange);
      return;
    }

    final success = await SettingsService.instance.setSmsDelaySeconds(newDelay);
    if (success) {
      setState(() {
        _currentDelay = newDelay;
      });
      widget.onDelayChanged?.call();
      _showSuccessSnackBar(
        AppLocalizations.of(context).currentDelay(_currentDelay),
      );
    } else {
      _showErrorSnackBar('Failed to update delay settings');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).delayBetweenMessages,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).delayDescription,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        // Current delay display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).currentDelay(_currentDelay),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Delay slider
        Row(
          children: [
            const Text('1'),
            Expanded(
              child: Slider(
                value: _currentDelay.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: '${_currentDelay}s',
                onChanged: (value) {
                  setState(() {
                    _currentDelay = value.round();
                  });
                },
                onChangeEnd: (value) {
                  _updateDelay(value.round());
                },
              ),
            ),
            const Text('30'),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).secondsShort,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick preset buttons
        Wrap(
          spacing: 8,
          children: [
            _buildPresetButton(1),
            _buildPresetButton(2),
            _buildPresetButton(5),
            _buildPresetButton(10),
            _buildPresetButton(15),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(int seconds) {
    final isSelected = _currentDelay == seconds;
    return FilterChip(
      label: Text('${seconds}s'),
      selected: isSelected,
      onSelected: (_) => _updateDelay(seconds),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

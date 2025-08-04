import 'package:shared_preferences/shared_  /// Validate delay value
  static bool isValidDelay(int seconds) {
    return seconds >= 0 && seconds <= 30;
  }erences.dart';

class SettingsService {
  static const String _smsDelayKey = 'sms_delay_seconds';
  static const String _selectedSimSlotKey = 'selected_sim_slot';
  static const int _defaultDelaySeconds = 1;

  static SettingsService? _instance;

  static SettingsService get instance {
    _instance ??= SettingsService._internal();
    return _instance!;
  }

  SettingsService._internal();

  /// Get the current SMS delay in seconds
  Future<int> getSmsDelaySeconds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_smsDelayKey) ?? _defaultDelaySeconds;
    } catch (e) {
      return _defaultDelaySeconds;
    }
  }

  /// Set the SMS delay in seconds
  Future<bool> setSmsDelaySeconds(int seconds) async {
    try {
      if (seconds < 0 || seconds > 30) {
        throw ArgumentError('Delay must be between 0 and 30 seconds');
      }
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_smsDelayKey, seconds);
    } catch (e) {
      return false;
    }
  }

  /// Get default delay seconds
  static int get defaultDelaySeconds => _defaultDelaySeconds;

  /// Validate delay value
  static bool isValidDelay(int seconds) {
    return seconds >= 1 && seconds <= 30;
  }

  /// Get the selected SIM slot
  Future<int?> getSelectedSimSlot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_selectedSimSlotKey);
    } catch (e) {
      return null;
    }
  }

  /// Set the selected SIM slot
  Future<bool> setSelectedSimSlot(int? simSlot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (simSlot == null) {
        return await prefs.remove(_selectedSimSlotKey);
      }
      return await prefs.setInt(_selectedSimSlotKey, simSlot);
    } catch (e) {
      return false;
    }
  }
}

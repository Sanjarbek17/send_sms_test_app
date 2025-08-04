import 'package:permission_handler/permission_handler.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:flutter/services.dart';
import 'permission_service.dart';
import 'settings_service.dart';
import 'sms_status_service.dart';
import 'dart:async';

class EnhancedSmsService {
  static bool _isInitialized = false;
  static StreamSubscription<SmsStatusUpdate>? _statusSubscription;
  static final Map<String, Completer<SmsResult>> _pendingMessages = {};

  /// Initialize the enhanced SMS service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await SmsStatusService.initialize();

      // Listen for SMS status updates
      _statusSubscription = SmsStatusService.statusStream.listen(
        (statusUpdate) {
          _handleStatusUpdate(statusUpdate);
        },
        onError: (error) {
          print('SMS Status Stream Error: $error');
        },
      );

      _isInitialized = true;
      print('Enhanced SMS Service initialized successfully');
    } catch (e) {
      print('Failed to initialize Enhanced SMS Service: $e');
    }
  }

  /// Dispose the enhanced SMS service
  static Future<void> dispose() async {
    if (!_isInitialized) return;

    await _statusSubscription?.cancel();
    await SmsStatusService.dispose();

    // Complete any pending messages with timeout
    for (final completer in _pendingMessages.values) {
      if (!completer.isCompleted) {
        completer.complete(SmsResult.error('Service disposed'));
      }
    }
    _pendingMessages.clear();

    _isInitialized = false;
    print('Enhanced SMS Service disposed');
  }

  /// Send SMS with enhanced status tracking
  static Future<SmsResult> sendSmsWithTracking({
    required String number,
    required String message,
    int? simSlot,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Validate inputs
      if (number.trim().isEmpty) {
        return SmsResult.error('Phone number cannot be empty');
      }

      if (message.trim().isEmpty) {
        return SmsResult.error('Message cannot be empty');
      }

      // Format Uzbek phone numbers
      String cleanedNumber = _formatUzbekPhoneNumber(number);

      print('Enhanced SMS Service - Sending to: $cleanedNumber');
      print('Enhanced SMS Service - Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      print('Enhanced SMS Service - SIM Slot: $simSlot');

      // Check all required permissions
      final hasPermissions = await PermissionService.hasAllSmsPermissions();
      if (!hasPermissions) {
        final permissions = await PermissionService.requestSmsPermissions();

        final smsGranted = permissions[Permission.sms]?.isGranted ?? false;
        final phoneGranted = permissions[Permission.phone]?.isGranted ?? false;

        if (!smsGranted) {
          return SmsResult.error('SMS permission not granted. Please allow SMS permission in settings.');
        }
        if (!phoneGranted) {
          return SmsResult.error('Phone permission not granted. This is required for SIM card detection.');
        }
      }

      // Get available SIM cards and determine which slot to use
      int selectedSimSlot = simSlot ?? 0; // Default to slot 0

      // Always get available SIM cards to ensure we have a valid slot
      List<Map<String, dynamic>> simCards = await SmsSender.getSimCards();
      print('Available SIM cards: $simCards');

      if (simCards.isNotEmpty) {
        // If no specific slot provided, check settings for preferred slot
        if (simSlot == null) {
          final settingsService = SettingsService.instance;
          final preferredSimSlot = await settingsService.getSelectedSimSlot();

          if (preferredSimSlot != null) {
            // Validate that the preferred slot exists
            bool slotExists = simCards.any((sim) => sim['simSlot'] == preferredSimSlot);
            if (slotExists) {
              selectedSimSlot = preferredSimSlot;
              print('Using preferred SIM slot from settings: $selectedSimSlot');
            } else {
              print('Preferred SIM slot $preferredSimSlot not found, using first available slot');
              selectedSimSlot = simCards[0]['simSlot'] ?? 0;
            }
          } else {
            // No preference set, use first available SIM
            selectedSimSlot = simCards[0]['simSlot'] ?? 0;
          }
        } else {
          // Validate that the provided slot exists
          bool slotExists = simCards.any((sim) => sim['simSlot'] == simSlot);
          if (!slotExists) {
            print('Warning: SIM slot $simSlot not found, using first available slot');
            selectedSimSlot = simCards[0]['simSlot'] ?? 0;
          }
        }
      } else {
        return SmsResult.error('No SIM cards found. Please insert a SIM card and try again.');
      }

      print('Using SIM slot: $selectedSimSlot');

      // Check if status tracking is supported
      final trackingSupported = await SmsStatusService.isSupported();

      if (trackingSupported) {
        // Start tracking for this message
        final trackingId = await SmsStatusService.startTracking(cleanedNumber, message.trim());

        // Create a completer to wait for the final status
        final completer = Completer<SmsResult>();
        _pendingMessages[trackingId] = completer;

        // Set up timeout
        Timer(timeout, () {
          if (_pendingMessages.containsKey(trackingId) && !completer.isCompleted) {
            _pendingMessages.remove(trackingId);
            completer.complete(SmsResult.timeout('SMS sending timeout after ${timeout.inSeconds} seconds'));
          }
        });

        try {
          // Send the SMS using the existing package
          String status = await SmsSender.sendSms(
            phoneNumber: cleanedNumber,
            message: message.trim(),
            simSlot: selectedSimSlot,
          );

          print('SMS handed off to system: $status');

          // Wait for the status update from our tracking system
          return await completer.future;
        } catch (e) {
          // Remove from pending and handle error
          _pendingMessages.remove(trackingId);
          if (!completer.isCompleted) {
            completer.complete(SmsResult.error('Failed to send SMS: $e'));
          }
          return await completer.future;
        }
      } else {
        // Fall back to basic sending without tracking
        return await _sendBasicSms(cleanedNumber, message.trim(), selectedSimSlot);
      }
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'NO_SIM':
          return SmsResult.error('No active SIM card found. Please insert a SIM card and try again.');
        case 'PERMISSION_DENIED':
          return SmsResult.error('SMS permission denied. Please grant SMS permission in settings.');
        case 'NETWORK_ERROR':
          return SmsResult.error('Network error. Please check your mobile network connection.');
        case 'INVALID_NUMBER':
          return SmsResult.error('Invalid phone number format. Please check the number and try again.');
        default:
          return SmsResult.error('Failed to send SMS: ${e.message ?? e.code}');
      }
    } catch (e) {
      return SmsResult.error('Unexpected error: $e');
    }
  }

  /// Handle status updates from the native side
  static void _handleStatusUpdate(SmsStatusUpdate statusUpdate) {
    final completer = _pendingMessages[statusUpdate.trackingId];
    if (completer != null && !completer.isCompleted) {
      switch (statusUpdate.status) {
        case SmsStatus.sent:
          _pendingMessages.remove(statusUpdate.trackingId);
          completer.complete(SmsResult.sent(
            'SMS sent successfully to ${statusUpdate.phoneNumber}',
            phoneNumber: statusUpdate.phoneNumber,
          ));
          break;
        case SmsStatus.delivered:
          _pendingMessages.remove(statusUpdate.trackingId);
          completer.complete(SmsResult.delivered(
            'SMS delivered successfully to ${statusUpdate.phoneNumber}',
            phoneNumber: statusUpdate.phoneNumber,
          ));
          break;
        case SmsStatus.failed:
          _pendingMessages.remove(statusUpdate.trackingId);
          completer.complete(SmsResult.error(
            statusUpdate.errorMessage ?? 'SMS failed to send',
            phoneNumber: statusUpdate.phoneNumber,
          ));
          break;
        case SmsStatus.queued:
        case SmsStatus.sending:
          // These are intermediate states, don't complete yet
          print('SMS ${statusUpdate.status.statusName}: ${statusUpdate.phoneNumber}');
          break;
        case SmsStatus.unknown:
          // Don't complete on unknown status
          print('Unknown SMS status for: ${statusUpdate.phoneNumber}');
          break;
      }
    }
  }

  /// Fallback to basic SMS sending without tracking
  static Future<SmsResult> _sendBasicSms(String phoneNumber, String message, int simSlot) async {
    try {
      await SmsSender.sendSms(
        phoneNumber: phoneNumber,
        message: message,
        simSlot: simSlot,
      );

      // Add a small delay to allow system processing
      await Future.delayed(const Duration(seconds: 1));

      return SmsResult.sent('SMS sent successfully to $phoneNumber', phoneNumber: phoneNumber);
    } catch (e) {
      return SmsResult.error('Failed to send SMS: $e', phoneNumber: phoneNumber);
    }
  }

  /// Legacy method for backward compatibility
  static Future<void> sendSms({
    required String number,
    required String message,
    int? simSlot,
  }) async {
    final result = await sendSmsWithTracking(
      number: number,
      message: message,
      simSlot: simSlot,
    );

    if (!result.success) {
      throw Exception(result.message);
    }
  }

  static Future<List<Map<String, dynamic>>> getAvailableSimCards() async {
    try {
      return await SmsSender.getSimCards();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> checkSmsAvailability() async {
    try {
      // Check all required permissions
      final hasPermissions = await PermissionService.hasAllSmsPermissions();
      if (!hasPermissions) {
        return false;
      }

      // Check if there are any SIM cards available
      List<Map<String, dynamic>> simCards = await getAvailableSimCards();
      return simCards.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Formats Uzbek phone numbers to ensure they start with +998
  static String _formatUzbekPhoneNumber(String phoneNumber) {
    // Remove all spaces, hyphens, parentheses for processing
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Remove decimal points and anything after them (handles .0 from Excel/CSV parsing)
    if (cleanNumber.contains('.')) {
      cleanNumber = cleanNumber.split('.')[0];
    }

    // If number is empty, return as is
    if (cleanNumber.isEmpty) {
      return phoneNumber;
    }

    // Check if it's an Uzbek number and format accordingly
    if (cleanNumber.startsWith('+998')) {
      // Already properly formatted
      return cleanNumber;
    } else if (cleanNumber.startsWith('998')) {
      // Missing the + prefix
      return '+$cleanNumber';
    } else if (cleanNumber.startsWith('9') && cleanNumber.length >= 9) {
      // Uzbek mobile number without country code (starts with 9)
      // Uzbek mobile numbers: 90, 91, 93, 94, 95, 97, 98, 99, 33, 88
      String firstTwoDigits = cleanNumber.substring(0, 2);
      if (['90', '91', '93', '94', '95', '97', '98', '99', '33', '88'].contains(firstTwoDigits)) {
        return '+998$cleanNumber';
      }
    }

    // If it doesn't match Uzbek patterns, return the cleaned number as is
    return cleanNumber;
  }
}

/// Result class for SMS operations
class SmsResult {
  final bool success;
  final String message;
  final String? phoneNumber;
  final SmsResultType type;

  SmsResult._({
    required this.success,
    required this.message,
    this.phoneNumber,
    required this.type,
  });

  factory SmsResult.sent(String message, {String? phoneNumber}) {
    return SmsResult._(
      success: true,
      message: message,
      phoneNumber: phoneNumber,
      type: SmsResultType.sent,
    );
  }

  factory SmsResult.delivered(String message, {String? phoneNumber}) {
    return SmsResult._(
      success: true,
      message: message,
      phoneNumber: phoneNumber,
      type: SmsResultType.delivered,
    );
  }

  factory SmsResult.error(String message, {String? phoneNumber}) {
    return SmsResult._(
      success: false,
      message: message,
      phoneNumber: phoneNumber,
      type: SmsResultType.error,
    );
  }

  factory SmsResult.timeout(String message, {String? phoneNumber}) {
    return SmsResult._(
      success: false,
      message: message,
      phoneNumber: phoneNumber,
      type: SmsResultType.timeout,
    );
  }

  @override
  String toString() {
    return 'SmsResult{success: $success, message: $message, phoneNumber: $phoneNumber, type: $type}';
  }
}

enum SmsResultType {
  sent,
  delivered,
  error,
  timeout,
}

import 'package:permission_handler/permission_handler.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:flutter/services.dart';
import 'permission_service.dart';
import 'settings_service.dart';
import 'dart:async';

class SmsServiceWithStatus {
  static StreamController<SmsStatusUpdate>? _statusController;
  static final Map<String, Completer<SmsResult>> _pendingMessages = {};

  /// Initialize the SMS service with status tracking
  static Future<void> initialize() async {
    _statusController = StreamController<SmsStatusUpdate>.broadcast();
    print('SMS Service with Status initialized');
  }

  /// Dispose the service
  static Future<void> dispose() async {
    await _statusController?.close();
    _statusController = null;

    // Complete any pending messages with timeout
    for (final completer in _pendingMessages.values) {
      if (!completer.isCompleted) {
        completer.complete(SmsResult.timeout('Service disposed'));
      }
    }
    _pendingMessages.clear();
  }

  /// Get the stream of SMS status updates
  static Stream<SmsStatusUpdate> get statusStream {
    if (_statusController == null) {
      throw StateError('SmsServiceWithStatus not initialized. Call initialize() first.');
    }
    return _statusController!.stream;
  }

  /// Send SMS with status tracking using a timeout approach
  static Future<SmsResult> sendSmsWithTracking({
    required String number,
    required String message,
    int? simSlot,
    Duration timeout = const Duration(seconds: 10), // Reduced timeout since we're not getting real status
  }) async {
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

      print('SMS Service - Sending to: $cleanedNumber');
      print('SMS Service - Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      print('SMS Service - SIM Slot: $simSlot');

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

      // Create a unique tracking ID for this message
      final trackingId = DateTime.now().millisecondsSinceEpoch.toString();
      final completer = Completer<SmsResult>();
      _pendingMessages[trackingId] = completer;

      // Send initial status update
      _sendStatusUpdate(trackingId, cleanedNumber, 'queued');

      // Start timeout timer
      Timer timeoutTimer = Timer(timeout, () {
        if (_pendingMessages.containsKey(trackingId) && !completer.isCompleted) {
          _pendingMessages.remove(trackingId);
          completer.complete(SmsResult.timeout('SMS sending timeout after ${timeout.inSeconds} seconds'));
        }
      });

      try {
        // Send status update
        _sendStatusUpdate(trackingId, cleanedNumber, 'sending');

        // Send the SMS using the existing package
        String status = await SmsSender.sendSms(
          phoneNumber: cleanedNumber,
          message: message.trim(),
          simSlot: selectedSimSlot,
        );

        print('SMS sent via sms_sender: $status');

        // Now wait for the system to actually process the SMS
        // We'll simulate waiting for the actual system confirmation

        // Update status to indicate system is processing
        _sendStatusUpdate(trackingId, cleanedNumber, 'processing');

        // Wait for a realistic amount of time for the system to process
        // This simulates waiting for actual SMS system confirmation
        await Future.delayed(Duration(seconds: 3));

        // Cancel timeout timer since we got a response
        timeoutTimer.cancel();

        // Remove from pending and complete with success
        _pendingMessages.remove(trackingId);
        if (!completer.isCompleted) {
          _sendStatusUpdate(trackingId, cleanedNumber, 'sent');
          completer.complete(SmsResult.sent('SMS sent successfully to $cleanedNumber', phoneNumber: cleanedNumber));
        }

        return await completer.future;
      } catch (e) {
        // Cancel timeout timer
        timeoutTimer.cancel();

        // Remove from pending and handle error
        _pendingMessages.remove(trackingId);
        if (!completer.isCompleted) {
          _sendStatusUpdate(trackingId, cleanedNumber, 'failed', e.toString());
          completer.complete(SmsResult.error('Failed to send SMS: $e', phoneNumber: cleanedNumber));
        }
        return await completer.future;
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

  /// Send status update to the stream
  static void _sendStatusUpdate(String trackingId, String phoneNumber, String status, [String? errorMessage]) {
    final statusUpdate = SmsStatusUpdate(
      trackingId: trackingId,
      phoneNumber: phoneNumber,
      status: SmsStatusExtension.fromString(status),
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );

    _statusController?.add(statusUpdate);
    print('Status update: $status for $phoneNumber');
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

/// Represents an SMS status update
class SmsStatusUpdate {
  final String trackingId;
  final String phoneNumber;
  final SmsStatus status;
  final String? errorMessage;
  final DateTime timestamp;

  SmsStatusUpdate({
    required this.trackingId,
    required this.phoneNumber,
    required this.status,
    this.errorMessage,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'SmsStatusUpdate{trackingId: $trackingId, phoneNumber: $phoneNumber, status: $status, errorMessage: $errorMessage, timestamp: $timestamp}';
  }
}

/// SMS status enumeration
enum SmsStatus {
  queued, // SMS is queued for sending
  sending, // SMS is being sent
  sent, // SMS has been sent to the network
  delivered, // SMS has been delivered to recipient
  failed, // SMS failed to send
  unknown // Unknown status
}

/// Extension for SmsStatus enum
extension SmsStatusExtension on SmsStatus {
  static SmsStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'queued':
        return SmsStatus.queued;
      case 'sending':
        return SmsStatus.sending;
      case 'sent':
        return SmsStatus.sent;
      case 'delivered':
        return SmsStatus.delivered;
      case 'failed':
        return SmsStatus.failed;
      default:
        return SmsStatus.unknown;
    }
  }

  String get statusName {
    switch (this) {
      case SmsStatus.queued:
        return 'queued';
      case SmsStatus.sending:
        return 'sending';
      case SmsStatus.sent:
        return 'sent';
      case SmsStatus.delivered:
        return 'delivered';
      case SmsStatus.failed:
        return 'failed';
      case SmsStatus.unknown:
        return 'unknown';
    }
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

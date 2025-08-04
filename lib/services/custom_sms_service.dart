import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart';
import 'settings_service.dart';
import 'dart:async';

class CustomSmsService {
  static const MethodChannel _methodChannel = MethodChannel('custom_sms_channel');
  static const EventChannel _eventChannel = EventChannel('custom_sms_events');

  static StreamController<SmsStatusUpdate>? _statusController;
  static StreamSubscription? _eventSubscription;
  static final Map<String, Completer<SmsResult>> _pendingMessages = {};
  static bool _isInitialized = false;

  /// Initialize the custom SMS service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _statusController = StreamController<SmsStatusUpdate>.broadcast();

    try {
      // Start listening for SMS status events from native side
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            final statusUpdate = SmsStatusUpdate.fromMap(Map<String, dynamic>.from(event));
            _statusController?.add(statusUpdate);
            _handleStatusUpdate(statusUpdate);
          }
        },
        onError: (error) {
          print('Custom SMS Event Channel Error: $error');
        },
      );

      _isInitialized = true;
      print('Custom SMS Service initialized successfully');
    } catch (e) {
      print('Failed to initialize Custom SMS Service: $e');
    }
  }

  /// Dispose the custom SMS service
  static Future<void> dispose() async {
    if (!_isInitialized) return;

    await _eventSubscription?.cancel();
    await _statusController?.close();
    _statusController = null;
    _eventSubscription = null;

    // Complete any pending messages with timeout
    for (final completer in _pendingMessages.values) {
      if (!completer.isCompleted) {
        completer.complete(SmsResult.error('Service disposed'));
      }
    }
    _pendingMessages.clear();

    _isInitialized = false;
    print('Custom SMS Service disposed');
  }

  /// Get the stream of SMS status updates
  static Stream<SmsStatusUpdate> get statusStream {
    if (_statusController == null) {
      throw StateError('CustomSmsService not initialized. Call initialize() first.');
    }
    return _statusController!.stream;
  }

  /// Send SMS with real status tracking
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

      print('Custom SMS Service - Sending to: $cleanedNumber');
      print('Custom SMS Service - Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      print('Custom SMS Service - SIM Slot: $simSlot');

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

      // Get available SIM cards using our custom method
      List<Map<String, dynamic>> simCards = await getAvailableSimCards();
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

      // Create a completer to wait for the final status
      final completer = Completer<SmsResult>();

      // Set up timeout
      Timer timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.complete(SmsResult.timeout('SMS sending timeout after ${timeout.inSeconds} seconds'));
        }
      });

      try {
        // Send SMS using our custom method channel
        final result = await _methodChannel.invokeMethod('sendSms', {
          'phoneNumber': cleanedNumber,
          'message': message.trim(),
          'simSlot': selectedSimSlot,
        });

        if (result is Map) {
          final sendId = result['sendId'] as String?;
          final resultMessage = result['message'] as String?;

          print('SMS send initiated: $resultMessage (ID: $sendId)');

          if (sendId != null) {
            // Store the completer for this send ID
            _pendingMessages[sendId] = completer;

            // Wait for the status update from the native side
            final smsResult = await completer.future;

            // Cancel timeout timer
            timeoutTimer.cancel();

            return smsResult;
          } else {
            timeoutTimer.cancel();
            return SmsResult.error('Failed to get send ID from native method');
          }
        } else {
          timeoutTimer.cancel();
          return SmsResult.error('Invalid response from native method');
        }
      } catch (e) {
        timeoutTimer.cancel();
        return SmsResult.error('Failed to send SMS: $e');
      }
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'PERMISSION_DENIED':
          return SmsResult.error('SMS permission denied. Please grant SMS permission in settings.');
        case 'NO_CONTEXT':
          return SmsResult.error('Application context not available.');
        case 'SEND_FAILED':
          return SmsResult.error('Failed to send SMS: ${e.message}');
        default:
          return SmsResult.error('Platform error: ${e.message ?? e.code}');
      }
    } catch (e) {
      return SmsResult.error('Unexpected error: $e');
    }
  }

  /// Handle status updates from the native side
  static void _handleStatusUpdate(SmsStatusUpdate statusUpdate) {
    final completer = _pendingMessages[statusUpdate.sendId];
    if (completer != null && !completer.isCompleted) {
      switch (statusUpdate.status) {
        case SmsStatus.sent:
          _pendingMessages.remove(statusUpdate.sendId);
          completer.complete(SmsResult.sent(
            'SMS sent successfully to ${statusUpdate.phoneNumber}',
            phoneNumber: statusUpdate.phoneNumber,
          ));
          break;
        case SmsStatus.delivered:
          _pendingMessages.remove(statusUpdate.sendId);
          completer.complete(SmsResult.delivered(
            'SMS delivered successfully to ${statusUpdate.phoneNumber}',
            phoneNumber: statusUpdate.phoneNumber,
          ));
          break;
        case SmsStatus.failed:
          _pendingMessages.remove(statusUpdate.sendId);
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

  /// Get available SIM cards using our custom method
  static Future<List<Map<String, dynamic>>> getAvailableSimCards() async {
    try {
      final result = await _methodChannel.invokeMethod('getSimCards');
      if (result is List) {
        return result.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Failed to get SIM cards: $e');
      return [];
    }
  }

  /// Check if SMS permissions are granted using our custom method
  static Future<bool> checkSmsAvailability() async {
    try {
      final result = await _methodChannel.invokeMethod('hasPermissions');
      return result as bool? ?? false;
    } catch (e) {
      print('Failed to check SMS permissions: $e');
      return false;
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

/// Represents an SMS status update from native code
class SmsStatusUpdate {
  final String sendId;
  final String phoneNumber;
  final SmsStatus status;
  final String? errorMessage;
  final DateTime timestamp;

  SmsStatusUpdate({
    required this.sendId,
    required this.phoneNumber,
    required this.status,
    this.errorMessage,
    required this.timestamp,
  });

  factory SmsStatusUpdate.fromMap(Map<String, dynamic> map) {
    return SmsStatusUpdate(
      sendId: map['sendId'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      status: SmsStatusExtension.fromString(map['status'] as String? ?? 'unknown'),
      errorMessage: map['errorMessage'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'SmsStatusUpdate{sendId: $sendId, phoneNumber: $phoneNumber, status: $status, errorMessage: $errorMessage, timestamp: $timestamp}';
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

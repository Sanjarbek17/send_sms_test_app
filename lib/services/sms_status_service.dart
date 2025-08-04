import 'package:flutter/services.dart';
import 'dart:async';

/// Service for tracking SMS status using custom platform channels
class SmsStatusService {
  static const MethodChannel _channel = MethodChannel('sms_status_channel');
  static const EventChannel _eventChannel = EventChannel('sms_status_event_channel');

  static StreamController<SmsStatusUpdate>? _statusController;
  static StreamSubscription? _eventSubscription;

  /// Initialize the SMS status service
  static Future<void> initialize() async {
    _statusController = StreamController<SmsStatusUpdate>.broadcast();

    try {
      // Start listening for SMS status events from native side
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            final statusUpdate = SmsStatusUpdate.fromMap(Map<String, dynamic>.from(event));
            _statusController?.add(statusUpdate);
          }
        },
        onError: (error) {
          print('SMS Status Event Channel Error: $error');
        },
      );

      print('SMS Status Service initialized successfully');
    } catch (e) {
      print('Failed to initialize SMS Status Service: $e');
    }
  }

  /// Dispose the SMS status service
  static Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _statusController?.close();
    _statusController = null;
    _eventSubscription = null;
  }

  /// Get the stream of SMS status updates
  static Stream<SmsStatusUpdate> get statusStream {
    if (_statusController == null) {
      throw StateError('SmsStatusService not initialized. Call initialize() first.');
    }
    return _statusController!.stream;
  }

  /// Start tracking SMS status for a specific message
  static Future<String> startTracking(String phoneNumber, String messageText) async {
    try {
      final result = await _channel.invokeMethod('startTracking', {
        'phoneNumber': phoneNumber,
        'messageText': messageText,
      });
      return result as String? ?? 'tracking_started';
    } catch (e) {
      print('Failed to start SMS tracking: $e');
      return 'tracking_failed';
    }
  }

  /// Stop tracking SMS status
  static Future<void> stopTracking() async {
    try {
      await _channel.invokeMethod('stopTracking');
    } catch (e) {
      print('Failed to stop SMS tracking: $e');
    }
  }

  /// Check if SMS status tracking is supported on this device
  static Future<bool> isSupported() async {
    try {
      final result = await _channel.invokeMethod('isSupported');
      return result as bool? ?? false;
    } catch (e) {
      print('Failed to check SMS status support: $e');
      return false;
    }
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

  factory SmsStatusUpdate.fromMap(Map<String, dynamic> map) {
    return SmsStatusUpdate(
      trackingId: map['trackingId'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      status: SmsStatusExtension.fromString(map['status'] as String? ?? 'unknown'),
      errorMessage: map['errorMessage'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trackingId': trackingId,
      'phoneNumber': phoneNumber,
      'status': status.statusName,
      'errorMessage': errorMessage,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

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

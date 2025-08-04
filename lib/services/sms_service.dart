import 'package:permission_handler/permission_handler.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:flutter/services.dart';
import 'permission_service.dart';

class SmsService {
  static Future<void> sendSms({
    required String number,
    required String message,
    int? simSlot,
  }) async {
    try {
      // Validate inputs
      if (number.trim().isEmpty) {
        throw Exception('Phone number cannot be empty');
      }

      if (message.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      // Clean phone number - remove any extra spaces or formatting
      String cleanedNumber = number.trim().replaceAll(RegExp(r'[^\d+\-\(\)\s]'), '');

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
          throw Exception('SMS permission not granted. Please allow SMS permission in settings.');
        }
        if (!phoneGranted) {
          throw Exception('Phone permission not granted. This is required for SIM card detection.');
        }
      }

      // Get available SIM cards if no specific slot is provided
      int selectedSimSlot = simSlot ?? 0; // Default to slot 0

      // Always get available SIM cards to ensure we have a valid slot
      List<Map<String, dynamic>> simCards = await SmsSender.getSimCards();
      print('Available SIM cards: $simCards');

      if (simCards.isNotEmpty) {
        // If no specific slot provided, use the first available SIM
        if (simSlot == null) {
          selectedSimSlot = simCards[0]['simSlot'] ?? 0;
        } else {
          // Validate that the provided slot exists
          bool slotExists = simCards.any((sim) => sim['simSlot'] == simSlot);
          if (!slotExists) {
            print('Warning: SIM slot $simSlot not found, using first available slot');
            selectedSimSlot = simCards[0]['simSlot'] ?? 0;
          }
        }
      } else {
        throw Exception('No SIM cards found. Please insert a SIM card and try again.');
      }

      print('Using SIM slot: $selectedSimSlot');

      await SmsSender.sendSms(
        phoneNumber: cleanedNumber,
        message: message.trim(),
        simSlot: selectedSimSlot,
      );
      await Future.delayed(const Duration(seconds: 1));
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'NO_SIM':
          throw Exception('No active SIM card found. Please insert a SIM card and try again.');
        case 'PERMISSION_DENIED':
          throw Exception('SMS permission denied. Please grant SMS permission in settings.');
        case 'NETWORK_ERROR':
          throw Exception('Network error. Please check your mobile network connection.');
        case 'INVALID_NUMBER':
          throw Exception('Invalid phone number format. Please check the number and try again.');
        default:
          throw Exception('Failed to send SMS: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
}

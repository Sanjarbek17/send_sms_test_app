import 'package:permission_handler/permission_handler.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:flutter/services.dart';
import 'permission_service.dart';
import 'settings_service.dart';

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
          throw Exception('SMS permission not granted. Please allow SMS permission in settings.');
        }
        if (!phoneGranted) {
          throw Exception('Phone permission not granted. This is required for SIM card detection.');
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

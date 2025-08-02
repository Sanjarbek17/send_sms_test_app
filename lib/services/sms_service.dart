import 'package:permission_handler/permission_handler.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:flutter/services.dart';

class SmsService {
  static Future<void> sendSms({
    required String number,
    required String message,
    int? simSlot,
  }) async {
    try {
      final permission = await Permission.sms.request();
      if (!permission.isGranted) {
        throw Exception('SMS permission not granted. Please allow SMS permission in settings.');
      }

      // Get available SIM cards if no specific slot is provided
      int selectedSimSlot = simSlot ?? 0; // Default to slot 0
      if (simSlot == null) {
        List<Map<String, dynamic>> simCards = await SmsSender.getSimCards();
        if (simCards.isNotEmpty) {
          selectedSimSlot = simCards[0]['simSlot'] ?? 0;
        }
      }

      await SmsSender.sendSms(
        phoneNumber: number,
        message: message,
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
      final permission = await Permission.sms.status;
      if (permission.isDenied || permission.isPermanentlyDenied) {
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

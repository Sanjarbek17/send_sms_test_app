import 'package:permission_handler/permission_handler.dart';
import 'package:sms_sender/sms_sender.dart';

class SmsService {
  static Future<void> sendSms({
    required String number,
    required String message,
  }) async {
    final permission = await Permission.sms.request();
    if (permission.isGranted) {
      await SmsSender.sendSms(phoneNumber: number, message: message);
      await Future.delayed(const Duration(seconds: 1));
    } else {
      throw Exception('SMS permission not granted');
    }
  }
}

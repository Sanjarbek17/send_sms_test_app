// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SMS Sender Pro';

  @override
  String get welcome => 'Welcome to SMS Sender Pro!';

  @override
  String get welcomeDescription =>
      'Your professional SMS broadcasting solution. Send messages to multiple contacts with ease.';

  @override
  String get smsServiceReady => 'SMS Service Ready';

  @override
  String get smsServiceUnavailable => 'SMS Service Unavailable';

  @override
  String get deviceReady => 'Your device is ready to send SMS messages';

  @override
  String get checkSimCard => 'Please check your SIM card and permissions';

  @override
  String get retryCheck => 'Retry Check';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get testSMS => 'Test SMS';

  @override
  String get sendTestMessage => 'Send test message';

  @override
  String get bulkSMS => 'Bulk SMS';

  @override
  String get sendToMultipleContacts => 'Send to multiple contacts';

  @override
  String get settings => 'Settings';

  @override
  String get configureAppSettings => 'Configure app settings';

  @override
  String get help => 'Help';

  @override
  String get troubleshootingGuide => 'Troubleshooting guide';

  @override
  String get keyFeatures => 'Key Features';

  @override
  String get bulkMessaging => 'Bulk Messaging';

  @override
  String get bulkMessagingDesc =>
      'Send SMS to multiple contacts from CSV/Excel files';

  @override
  String get securePrivate => 'Secure & Private';

  @override
  String get securePrivateDesc =>
      'All messages are sent directly from your device';

  @override
  String get dualSimSupport => 'Dual SIM Support';

  @override
  String get dualSimSupportDesc => 'Choose which SIM card to use for sending';

  @override
  String get progressTracking => 'Progress Tracking';

  @override
  String get progressTrackingDesc =>
      'Real-time progress monitoring during bulk sends';

  @override
  String get home => 'Home';

  @override
  String get testSMSFunctionality => 'Test SMS Functionality';

  @override
  String get testSMSDescription =>
      'Send a test message to verify your SMS setup before bulk sending. This helps ensure your device, SIM card, and permissions are working correctly.';

  @override
  String get tipTestWithOwnNumber => 'Tip: Test with your own number first';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get testPhoneNumber => 'Test Phone Number';

  @override
  String get enterPhoneNumber =>
      'Enter the phone number you want to test with (including country code)';

  @override
  String get testMessage => 'Test Message';

  @override
  String get enterTestMessage => 'Enter test message';

  @override
  String get testMessageHint =>
      'Hello! This is a test message from SMS Sender Pro.';

  @override
  String get writeTestMessage =>
      'Write a short test message to verify SMS functionality';

  @override
  String get clearAll => 'Clear All';

  @override
  String get sendTestMessageBtn => 'Send Test Message';

  @override
  String get sendingTest => 'Sending Test...';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter a phone number';

  @override
  String get pleaseEnterMessage => 'Please enter a message';

  @override
  String get pleaseEnterTestMessage => 'Please enter a test message';

  @override
  String get readyToSendTest => 'Ready to send test message';

  @override
  String get selectContactFile => 'Select Contact File';

  @override
  String get contactsLoaded => 'contacts loaded';

  @override
  String get readyToSendBulk => 'Ready to send bulk messages';

  @override
  String get messageContent => 'Message Content';

  @override
  String get enterYourMessage => 'Enter your message';

  @override
  String get messageHint =>
      'Type the message you want to send to all contacts...';

  @override
  String get helperText => 'This message will be sent to all selected contacts';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get sendToAllContacts => 'Send to All Contacts';

  @override
  String get sending => 'Sending...';

  @override
  String get pleaseSelectFile => 'Please select a contact file first';

  @override
  String get pleaseEnterMessageToSend => 'Please enter a message to send';

  @override
  String readyToSendToContacts(int count) {
    return 'Ready to send to $count contacts';
  }

  @override
  String get sendingProgress => 'Sending Progress';

  @override
  String messagesSent(int sent, int total) {
    return '$sent of $total messages sent';
  }

  @override
  String get smsServiceStatus => 'SMS Service Status';

  @override
  String get smsReady => 'SMS Ready';

  @override
  String get smsNotAvailable => 'SMS Not Available';

  @override
  String get deviceReadyForSMS => 'Your device is ready to send SMS messages';

  @override
  String get checkSimCardPermissions =>
      'Please check SIM card, permissions, and device SMS support';

  @override
  String get permissions => 'Permissions';

  @override
  String get simCardSelection => 'SIM Card Selection';

  @override
  String get appInformation => 'App Information';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get platform => 'Platform';

  @override
  String get smsTeam => 'SMS Sender Pro Team';

  @override
  String get androidIOS => 'Android & iOS';

  @override
  String get requestPermissions => 'Request Permissions';

  @override
  String get whyPermissions => 'Why these permissions?';

  @override
  String get granted => 'Granted';

  @override
  String get denied => 'Denied';

  @override
  String get permanentlyDenied => 'Permanently Denied';

  @override
  String get restricted => 'Restricted';

  @override
  String get unknown => 'Unknown';

  @override
  String get smsTroubleshooting => 'SMS Troubleshooting';

  @override
  String get troubleshootingIntro => 'If you\'re having trouble sending SMS:';

  @override
  String get simCardIssue => 'SIM Card';

  @override
  String get simCardDesc =>
      'Make sure your device has an active SIM card inserted and it\'s properly recognized.';

  @override
  String get permissionsIssue => 'Permissions';

  @override
  String get permissionsDesc =>
      'Grant SMS permissions to this app in your device settings.';

  @override
  String get networkIssue => 'Network';

  @override
  String get networkDesc => 'Ensure you have cellular network coverage.';

  @override
  String get phoneNumberFormat => 'Phone Number';

  @override
  String get phoneNumberDesc =>
      'Verify the phone number format is correct (include country code if needed).';

  @override
  String get deviceSupport => 'Device Support';

  @override
  String get deviceSupportDesc =>
      'Some emulators or devices may not support SMS functionality.';

  @override
  String get commonErrorCodes => 'Common Error Codes:';

  @override
  String get close => 'Close';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get ok => 'OK';

  @override
  String get testMessageSentSuccessfully => 'Test message sent successfully!';

  @override
  String failedToSendTestMessage(String error) {
    return 'Failed to send test message: $error';
  }

  @override
  String messagesSentSuccessfully(int count) {
    return 'Messages sent successfully to $count contacts!';
  }

  @override
  String failedToSendMessages(String error) {
    return 'Failed to send messages: $error';
  }

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get fileSelected => 'File Selected';

  @override
  String get chooseCSVExcelFile => 'Choose a CSV or Excel file with contacts';

  @override
  String get fileSelectedSuccessfully => 'File selected successfully';

  @override
  String get changeFile => 'Change File';

  @override
  String get pickFile => 'Pick File';

  @override
  String get configureColumnHeaders => 'Configure Column Headers';

  @override
  String get specifyColumnHeaders =>
      'Specify the column header names in your file:';

  @override
  String get nameColumnHeader => 'Name Column Header';

  @override
  String get nameColumnHint => 'e.g., name, full_name, customer';

  @override
  String get phoneColumnHeader => 'Phone Column Header';

  @override
  String get phoneColumnHint => 'e.g., phone, number, mobile';

  @override
  String get columnSearchNote =>
      'Note: The search is case-insensitive and matches partial text.';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueButton => 'Continue';

  @override
  String get troubleshootingSimCard => '1. SIM Card';

  @override
  String get troubleshootingSimCardDesc =>
      'Make sure your device has an active SIM card inserted and it\'s properly recognized.';

  @override
  String get troubleshootingPermissions => '2. Permissions';

  @override
  String get troubleshootingPermissionsDesc =>
      'Grant SMS permissions to this app in your device settings.';

  @override
  String get troubleshootingNetwork => '3. Network';

  @override
  String get troubleshootingNetworkDesc =>
      'Ensure you have cellular network coverage.';

  @override
  String get troubleshootingPhoneNumber => '4. Phone Number';

  @override
  String get troubleshootingPhoneNumberDesc =>
      'Verify the phone number format is correct (include country code if needed).';

  @override
  String get troubleshootingDeviceSupport => '5. Device Support';

  @override
  String get troubleshootingDeviceSupportDesc =>
      'Some emulators or devices may not support SMS functionality.';

  @override
  String get errorNoSim => 'NO_SIM';

  @override
  String get errorNoSimDesc => 'No active SIM card detected';

  @override
  String get errorPermissionDenied => 'PERMISSION_DENIED';

  @override
  String get errorPermissionDeniedDesc => 'SMS permission not granted';

  @override
  String get errorNetworkError => 'NETWORK_ERROR';

  @override
  String get errorNetworkErrorDesc => 'Network connectivity issue';

  @override
  String get errorInvalidNumber => 'INVALID_NUMBER';

  @override
  String get errorInvalidNumberDesc => 'Phone number format error';

  @override
  String get permissionsRequired => 'Permissions Required';

  @override
  String get permissionExplanation =>
      'This app requires the following permissions to function properly:';

  @override
  String get smsPermission => 'SMS Permission';

  @override
  String get smsPermissionDesc => 'Required to send text messages';

  @override
  String get phoneStatePermission => 'Phone State Permission';

  @override
  String get phoneStatePermissionDesc =>
      'Required to detect SIM cards and support dual SIM functionality';

  @override
  String get privacyNote =>
      'Note: These permissions are only used for SMS functionality and your privacy is protected.';

  @override
  String get checkingPermissions => 'Checking permissions...';

  @override
  String get permissionStatus => 'Permission Status';

  @override
  String get whyThesePermissions => 'Why these permissions?';

  @override
  String get smsApp => 'SMS Sender App';

  @override
  String get defaultNameHeader => 'name';

  @override
  String get defaultPhoneHeader => 'phone';
}

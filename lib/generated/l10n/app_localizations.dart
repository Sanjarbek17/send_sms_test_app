import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SMS Sender Pro'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to SMS Sender Pro!'**
  String get welcome;

  /// Welcome description
  ///
  /// In en, this message translates to:
  /// **'Your professional SMS broadcasting solution. Send messages to multiple contacts with ease.'**
  String get welcomeDescription;

  /// SMS service ready status
  ///
  /// In en, this message translates to:
  /// **'SMS Service Ready'**
  String get smsServiceReady;

  /// SMS service unavailable status
  ///
  /// In en, this message translates to:
  /// **'SMS Service Unavailable'**
  String get smsServiceUnavailable;

  /// Device ready message
  ///
  /// In en, this message translates to:
  /// **'Your device is ready to send SMS messages'**
  String get deviceReady;

  /// Check SIM card message
  ///
  /// In en, this message translates to:
  /// **'Please check your SIM card and permissions'**
  String get checkSimCard;

  /// Retry check button
  ///
  /// In en, this message translates to:
  /// **'Retry Check'**
  String get retryCheck;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Test SMS button
  ///
  /// In en, this message translates to:
  /// **'Test SMS'**
  String get testSMS;

  /// Send test message description
  ///
  /// In en, this message translates to:
  /// **'Send test message'**
  String get sendTestMessage;

  /// Bulk SMS button
  ///
  /// In en, this message translates to:
  /// **'Bulk SMS'**
  String get bulkSMS;

  /// Send to multiple contacts description
  ///
  /// In en, this message translates to:
  /// **'Send to multiple contacts'**
  String get sendToMultipleContacts;

  /// Settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Configure app settings description
  ///
  /// In en, this message translates to:
  /// **'Configure app settings'**
  String get configureAppSettings;

  /// Help button
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Troubleshooting guide description
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting guide'**
  String get troubleshootingGuide;

  /// Key features section title
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// Bulk messaging feature
  ///
  /// In en, this message translates to:
  /// **'Bulk Messaging'**
  String get bulkMessaging;

  /// Bulk messaging description
  ///
  /// In en, this message translates to:
  /// **'Send SMS to multiple contacts from CSV/Excel files'**
  String get bulkMessagingDesc;

  /// Secure and private feature
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get securePrivate;

  /// Secure and private description
  ///
  /// In en, this message translates to:
  /// **'All messages are sent directly from your device'**
  String get securePrivateDesc;

  /// Dual SIM support feature
  ///
  /// In en, this message translates to:
  /// **'Dual SIM Support'**
  String get dualSimSupport;

  /// Dual SIM support description
  ///
  /// In en, this message translates to:
  /// **'Choose which SIM card to use for sending'**
  String get dualSimSupportDesc;

  /// Progress tracking feature
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get progressTracking;

  /// Progress tracking description
  ///
  /// In en, this message translates to:
  /// **'Real-time progress monitoring during bulk sends'**
  String get progressTrackingDesc;

  /// Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Test SMS functionality title
  ///
  /// In en, this message translates to:
  /// **'Test SMS Functionality'**
  String get testSMSFunctionality;

  /// Test SMS description
  ///
  /// In en, this message translates to:
  /// **'Send a test message to verify your SMS setup before bulk sending. This helps ensure your device, SIM card, and permissions are working correctly.'**
  String get testSMSDescription;

  /// Tip for testing
  ///
  /// In en, this message translates to:
  /// **'Tip: Test with your own number first'**
  String get tipTestWithOwnNumber;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Test phone number label
  ///
  /// In en, this message translates to:
  /// **'Test Phone Number'**
  String get testPhoneNumber;

  /// Enter phone number hint
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number you want to test with (including country code)'**
  String get enterPhoneNumber;

  /// Test message label
  ///
  /// In en, this message translates to:
  /// **'Test Message'**
  String get testMessage;

  /// Enter test message hint
  ///
  /// In en, this message translates to:
  /// **'Enter test message'**
  String get enterTestMessage;

  /// Test message hint text
  ///
  /// In en, this message translates to:
  /// **'Hello! This is a test message from SMS Sender Pro.'**
  String get testMessageHint;

  /// Write test message description
  ///
  /// In en, this message translates to:
  /// **'Write a short test message to verify SMS functionality'**
  String get writeTestMessage;

  /// Clear all button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Send test message button
  ///
  /// In en, this message translates to:
  /// **'Send Test Message'**
  String get sendTestMessageBtn;

  /// Sending test status
  ///
  /// In en, this message translates to:
  /// **'Sending Test...'**
  String get sendingTest;

  /// Please enter phone number error
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get pleaseEnterPhoneNumber;

  /// Please enter message error
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get pleaseEnterMessage;

  /// Please enter test message error
  ///
  /// In en, this message translates to:
  /// **'Please enter a test message'**
  String get pleaseEnterTestMessage;

  /// Ready to send test message status
  ///
  /// In en, this message translates to:
  /// **'Ready to send test message'**
  String get readyToSendTest;

  /// Select contact file title
  ///
  /// In en, this message translates to:
  /// **'Select Contact File'**
  String get selectContactFile;

  /// Contacts loaded message
  ///
  /// In en, this message translates to:
  /// **'contacts loaded'**
  String get contactsLoaded;

  /// Ready to send bulk messages
  ///
  /// In en, this message translates to:
  /// **'Ready to send bulk messages'**
  String get readyToSendBulk;

  /// Message content title
  ///
  /// In en, this message translates to:
  /// **'Message Content'**
  String get messageContent;

  /// Enter your message label
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get enterYourMessage;

  /// Message hint text
  ///
  /// In en, this message translates to:
  /// **'Type the message you want to send to all contacts...'**
  String get messageHint;

  /// Helper text for message
  ///
  /// In en, this message translates to:
  /// **'This message will be sent to all selected contacts'**
  String get helperText;

  /// Clear all data button
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// Send to all contacts button
  ///
  /// In en, this message translates to:
  /// **'Send to All Contacts'**
  String get sendToAllContacts;

  /// Sending status
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// Please select file error
  ///
  /// In en, this message translates to:
  /// **'Please select a contact file first'**
  String get pleaseSelectFile;

  /// Please enter message to send error
  ///
  /// In en, this message translates to:
  /// **'Please enter a message to send'**
  String get pleaseEnterMessageToSend;

  /// Ready to send to contacts status
  ///
  /// In en, this message translates to:
  /// **'Ready to send to {count} contacts'**
  String readyToSendToContacts(int count);

  /// Sending progress title
  ///
  /// In en, this message translates to:
  /// **'Sending Progress'**
  String get sendingProgress;

  /// Messages sent progress
  ///
  /// In en, this message translates to:
  /// **'{sent} of {total} messages sent'**
  String messagesSent(int sent, int total);

  /// SMS service status title
  ///
  /// In en, this message translates to:
  /// **'SMS Service Status'**
  String get smsServiceStatus;

  /// SMS ready status
  ///
  /// In en, this message translates to:
  /// **'SMS Ready'**
  String get smsReady;

  /// SMS not available status
  ///
  /// In en, this message translates to:
  /// **'SMS Not Available'**
  String get smsNotAvailable;

  /// Device ready for SMS message
  ///
  /// In en, this message translates to:
  /// **'Your device is ready to send SMS messages'**
  String get deviceReadyForSMS;

  /// Check SIM card permissions message
  ///
  /// In en, this message translates to:
  /// **'Please check SIM card, permissions, and device SMS support'**
  String get checkSimCardPermissions;

  /// Permissions title
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// SIM card selection title
  ///
  /// In en, this message translates to:
  /// **'SIM Card Selection'**
  String get simCardSelection;

  /// App information title
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Developer label
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Platform label
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// SMS team name
  ///
  /// In en, this message translates to:
  /// **'SMS Sender Pro Team'**
  String get smsTeam;

  /// Android and iOS platforms
  ///
  /// In en, this message translates to:
  /// **'Android & iOS'**
  String get androidIOS;

  /// Request permissions button
  ///
  /// In en, this message translates to:
  /// **'Request Permissions'**
  String get requestPermissions;

  /// Why permissions tooltip
  ///
  /// In en, this message translates to:
  /// **'Why these permissions?'**
  String get whyPermissions;

  /// Permission granted status
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// Permission denied status
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get denied;

  /// Permission permanently denied status
  ///
  /// In en, this message translates to:
  /// **'Permanently Denied'**
  String get permanentlyDenied;

  /// Permission restricted status
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get restricted;

  /// Permission unknown status
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// SMS troubleshooting title
  ///
  /// In en, this message translates to:
  /// **'SMS Troubleshooting'**
  String get smsTroubleshooting;

  /// Troubleshooting intro text
  ///
  /// In en, this message translates to:
  /// **'If you\'re having trouble sending SMS:'**
  String get troubleshootingIntro;

  /// SIM card issue title
  ///
  /// In en, this message translates to:
  /// **'SIM Card'**
  String get simCardIssue;

  /// SIM card issue description
  ///
  /// In en, this message translates to:
  /// **'Make sure your device has an active SIM card inserted and it\'s properly recognized.'**
  String get simCardDesc;

  /// Permissions issue title
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsIssue;

  /// Permissions issue description
  ///
  /// In en, this message translates to:
  /// **'Grant SMS permissions to this app in your device settings.'**
  String get permissionsDesc;

  /// Network issue title
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkIssue;

  /// Network issue description
  ///
  /// In en, this message translates to:
  /// **'Ensure you have cellular network coverage.'**
  String get networkDesc;

  /// Phone number format issue title
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberFormat;

  /// Phone number format description
  ///
  /// In en, this message translates to:
  /// **'Verify the phone number format is correct (include country code if needed).'**
  String get phoneNumberDesc;

  /// Device support issue title
  ///
  /// In en, this message translates to:
  /// **'Device Support'**
  String get deviceSupport;

  /// Device support description
  ///
  /// In en, this message translates to:
  /// **'Some emulators or devices may not support SMS functionality.'**
  String get deviceSupportDesc;

  /// Common error codes title
  ///
  /// In en, this message translates to:
  /// **'Common Error Codes:'**
  String get commonErrorCodes;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Test message sent successfully
  ///
  /// In en, this message translates to:
  /// **'Test message sent successfully!'**
  String get testMessageSentSuccessfully;

  /// Failed to send test message
  ///
  /// In en, this message translates to:
  /// **'Failed to send test message: {error}'**
  String failedToSendTestMessage(String error);

  /// Messages sent successfully
  ///
  /// In en, this message translates to:
  /// **'Messages sent successfully to {count} contacts!'**
  String messagesSentSuccessfully(int count);

  /// Failed to send messages
  ///
  /// In en, this message translates to:
  /// **'Failed to send messages: {error}'**
  String failedToSendMessages(String error);

  /// No file selected status
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

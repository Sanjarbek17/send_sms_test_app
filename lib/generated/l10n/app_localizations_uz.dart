// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'SMS Yuboruvchi Pro';

  @override
  String get welcome => 'SMS Yuboruvchi Pro\'ga xush kelibsiz!';

  @override
  String get welcomeDescription =>
      'Sizning professional SMS eshittirish yechimingiz. Ko\'plab kontaktlarga oson SMS yuboring.';

  @override
  String get smsServiceReady => 'SMS Xizmati Tayyor';

  @override
  String get smsServiceUnavailable => 'SMS Xizmati Mavjud Emas';

  @override
  String get deviceReady => 'Qurilmangiz SMS yuborish uchun tayyor';

  @override
  String get checkSimCard => 'Iltimos, SIM kartangiz va ruxsatlarni tekshiring';

  @override
  String get retryCheck => 'Qayta Tekshirish';

  @override
  String get quickActions => 'Tez Amallar';

  @override
  String get testSMS => 'SMS Sinovi';

  @override
  String get sendTestMessage => 'Sinov xabarini yuborish';

  @override
  String get bulkSMS => 'Ommaviy SMS';

  @override
  String get sendToMultipleContacts => 'Ko\'plab kontaktlarga yuborish';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get configureAppSettings => 'Ilova sozlamalarini sozlash';

  @override
  String get help => 'Yordam';

  @override
  String get troubleshootingGuide => 'Muammolarni hal qilish qo\'llanmasi';

  @override
  String get keyFeatures => 'Asosiy Xususiyatlar';

  @override
  String get bulkMessaging => 'Ommaviy Xabar Yuborish';

  @override
  String get bulkMessagingDesc =>
      'CSV/Excel fayllaridan ko\'plab kontaktlarga SMS yuboring';

  @override
  String get securePrivate => 'Xavfsiz va Shaxsiy';

  @override
  String get securePrivateDesc =>
      'Barcha xabarlar to\'g\'ridan-to\'g\'ri qurilmangizdan yuboriladi';

  @override
  String get dualSimSupport => 'Ikki SIM Qo\'llab-quvvatlash';

  @override
  String get dualSimSupportDesc =>
      'Yuborish uchun qaysi SIM kartani tanlashni tanlang';

  @override
  String get progressTracking => 'Jarayon Kuzatuvi';

  @override
  String get progressTrackingDesc =>
      'Ommaviy yuborishlar paytida real vaqtda jarayon monitoring';

  @override
  String get home => 'Bosh sahifa';

  @override
  String get testSMSFunctionality => 'SMS Funksiyasini Sinash';

  @override
  String get testSMSDescription =>
      'Ommaviy yuborishdan oldin SMS sozlamalaringizni tekshirish uchun sinov xabarini yuboring. Bu qurilma, SIM karta va ruxsatlaringiz to\'g\'ri ishlashini ta\'minlashga yordam beradi.';

  @override
  String get tipTestWithOwnNumber =>
      'Maslahat: Avval o\'z raqamingiz bilan sinab ko\'ring';

  @override
  String get phoneNumber => 'Telefon Raqami';

  @override
  String get testPhoneNumber => 'Sinov Telefon Raqami';

  @override
  String get enterPhoneNumber =>
      'Sinov qilmoqchi bo\'lgan telefon raqamini kiriting (mamlakat kodini ham qo\'shib)';

  @override
  String get testMessage => 'Sinov Xabari';

  @override
  String get enterTestMessage => 'Sinov xabarini kiriting';

  @override
  String get testMessageHint =>
      'Salom! Bu SMS Yuboruvchi Pro\'dan sinov xabari.';

  @override
  String get writeTestMessage =>
      'SMS funksiyasini tekshirish uchun qisqa sinov xabarini yozing';

  @override
  String get clearAll => 'Hammasini Tozalash';

  @override
  String get sendTestMessageBtn => 'Sinov Xabarini Yuborish';

  @override
  String get sendingTest => 'Sinov Yuborilmoqda...';

  @override
  String get pleaseEnterPhoneNumber => 'Iltimos, telefon raqamini kiriting';

  @override
  String get pleaseEnterMessage => 'Iltimos, xabarni kiriting';

  @override
  String get pleaseEnterTestMessage => 'Iltimos, sinov xabarini kiriting';

  @override
  String get readyToSendTest => 'Sinov xabarini yuborishga tayyor';

  @override
  String get selectContactFile => 'Kontakt Faylini Tanlash';

  @override
  String get contactsLoaded => 'kontakt yuklandi';

  @override
  String get readyToSendBulk => 'Ommaviy xabarlar yuborishga tayyor';

  @override
  String get messageContent => 'Xabar Mazmuni';

  @override
  String get enterYourMessage => 'Xabaringizni kiriting';

  @override
  String get messageHint =>
      'Barcha kontaktlarga yubormoqchi bo\'lgan xabaringizni yozing...';

  @override
  String get helperText => 'Bu xabar barcha tanlangan kontaktlarga yuboriladi';

  @override
  String get clearAllData => 'Barcha Ma\'lumotlarni Tozalash';

  @override
  String get sendToAllContacts => 'Barcha Kontaktlarga Yuborish';

  @override
  String get sending => 'Yuborilmoqda...';

  @override
  String get pleaseSelectFile => 'Iltimos, avval kontakt faylini tanlang';

  @override
  String get pleaseEnterMessageToSend =>
      'Iltimos, yuborish uchun xabarni kiriting';

  @override
  String readyToSendToContacts(int count) {
    return '$count ta kontaktga yuborishga tayyor';
  }

  @override
  String get sendingProgress => 'Yuborish Jarayoni';

  @override
  String messagesSent(int sent, int total) {
    return '$total tadan $sent ta xabar yuborildi';
  }

  @override
  String get smsServiceStatus => 'SMS Xizmati Holati';

  @override
  String get smsReady => 'SMS Tayyor';

  @override
  String get smsNotAvailable => 'SMS Mavjud Emas';

  @override
  String get deviceReadyForSMS => 'Qurilmangiz SMS yuborish uchun tayyor';

  @override
  String get checkSimCardPermissions =>
      'Iltimos, SIM karta, ruxsatlar va qurilma SMS qo\'llab-quvvatlashini tekshiring';

  @override
  String get permissions => 'Ruxsatlar';

  @override
  String get simCardSelection => 'SIM Karta Tanlash';

  @override
  String get appInformation => 'Ilova Ma\'lumotlari';

  @override
  String get version => 'Versiya';

  @override
  String get developer => 'Ishlab chiquvchi';

  @override
  String get platform => 'Platforma';

  @override
  String get smsTeam => 'SMS Yuboruvchi Pro Jamoasi';

  @override
  String get androidIOS => 'Android va iOS';

  @override
  String get requestPermissions => 'Ruxsat So\'rash';

  @override
  String get whyPermissions => 'Nega bu ruxsatlar?';

  @override
  String get granted => 'Berilgan';

  @override
  String get denied => 'Rad etilgan';

  @override
  String get permanentlyDenied => 'Doimiy Rad Etilgan';

  @override
  String get restricted => 'Cheklangan';

  @override
  String get unknown => 'Noma\'lum';

  @override
  String get smsTroubleshooting => 'SMS Muammolarini Hal Qilish';

  @override
  String get troubleshootingIntro => 'Agar SMS yuborishda muammo bo\'lsa:';

  @override
  String get simCardIssue => 'SIM Karta';

  @override
  String get simCardDesc =>
      'Qurilmangizda faol SIM karta kiritilganligini va u to\'g\'ri tanilganligini tekshiring.';

  @override
  String get permissionsIssue => 'Ruxsatlar';

  @override
  String get permissionsDesc =>
      'Qurilma sozlamalarida bu ilovaga SMS ruxsatlarini bering.';

  @override
  String get networkIssue => 'Tarmoq';

  @override
  String get networkDesc => 'Uyali tarmoq qamrovi borligini tekshiring.';

  @override
  String get phoneNumberFormat => 'Telefon Raqami';

  @override
  String get phoneNumberDesc =>
      'Telefon raqami formati to\'g\'riligini tekshiring (kerak bo\'lsa mamlakat kodini qo\'shing).';

  @override
  String get deviceSupport => 'Qurilma Qo\'llab-quvvatlash';

  @override
  String get deviceSupportDesc =>
      'Ba\'zi emulyatorlar yoki qurilmalar SMS funksiyasini qo\'llab-quvvatlamaydi.';

  @override
  String get commonErrorCodes => 'Keng Tarqalgan Xato Kodlari:';

  @override
  String get close => 'Yopish';

  @override
  String get error => 'Xato';

  @override
  String get success => 'Muvaffaqiyat';

  @override
  String get ok => 'OK';

  @override
  String get testMessageSentSuccessfully =>
      'Sinov xabari muvaffaqiyatli yuborildi!';

  @override
  String failedToSendTestMessage(String error) {
    return 'Sinov xabarini yuborishda xato: $error';
  }

  @override
  String messagesSentSuccessfully(int count) {
    return '$count ta kontaktga xabarlar muvaffaqiyatli yuborildi!';
  }

  @override
  String failedToSendMessages(String error) {
    return 'Xabarlarni yuborishda xato: $error';
  }

  @override
  String get noFileSelected => 'Hech qanday fayl tanlanmagan';

  @override
  String get fileSelected => 'Fayl Tanlandi';

  @override
  String get chooseCSVExcelFile =>
      'Kontaktlar bilan CSV yoki Excel faylini tanlang';

  @override
  String get fileSelectedSuccessfully => 'Fayl muvaffaqiyatli tanlandi';

  @override
  String get changeFile => 'Faylni O\'zgartirish';

  @override
  String get pickFile => 'Fayl Tanlash';

  @override
  String get configureColumnHeaders => 'Ustun Sarlavhalarini Sozlash';

  @override
  String get specifyColumnHeaders =>
      'Faylingizda ustun sarlavhasi nomlarini belgilang:';

  @override
  String get nameColumnHeader => 'Ism Ustuni Sarlavhasi';

  @override
  String get nameColumnHint => 'masalan, ism, toliq_ism, mijoz';

  @override
  String get phoneColumnHeader => 'Telefon Ustuni Sarlavhasi';

  @override
  String get phoneColumnHint => 'masalan, telefon, raqam, mobil';

  @override
  String get columnSearchNote =>
      'Eslatma: Qidiruv katta-kichik harflarni farqlamaydi va qisman matnni moslashtiradi.';

  @override
  String get cancel => 'Bekor Qilish';

  @override
  String get continueButton => 'Davom Etish';

  @override
  String get troubleshootingSimCard => '1. SIM Karta';

  @override
  String get troubleshootingSimCardDesc =>
      'Qurilmangizda faol SIM karta kiritilganligini va u to\'g\'ri tanilganligini tekshiring.';

  @override
  String get troubleshootingPermissions => '2. Ruxsatlar';

  @override
  String get troubleshootingPermissionsDesc =>
      'Qurilma sozlamalarida bu ilovaga SMS ruxsatlarini bering.';

  @override
  String get troubleshootingNetwork => '3. Tarmoq';

  @override
  String get troubleshootingNetworkDesc =>
      'Uyali tarmoq qamrovi borligini tekshiring.';

  @override
  String get troubleshootingPhoneNumber => '4. Telefon Raqami';

  @override
  String get troubleshootingPhoneNumberDesc =>
      'Telefon raqami formati to\'g\'riligini tekshiring (kerak bo\'lsa mamlakat kodini qo\'shing).';

  @override
  String get troubleshootingDeviceSupport => '5. Qurilma Qo\'llab-quvvatlash';

  @override
  String get troubleshootingDeviceSupportDesc =>
      'Ba\'zi emulyatorlar yoki qurilmalar SMS funksiyasini qo\'llab-quvvatlamaydi.';

  @override
  String get errorNoSim => 'NO_SIM';

  @override
  String get errorNoSimDesc => 'Faol SIM karta aniqlanmadi';

  @override
  String get errorPermissionDenied => 'PERMISSION_DENIED';

  @override
  String get errorPermissionDeniedDesc => 'SMS ruxsati berilmagan';

  @override
  String get errorNetworkError => 'NETWORK_ERROR';

  @override
  String get errorNetworkErrorDesc => 'Tarmoq ulanish muammosi';

  @override
  String get errorInvalidNumber => 'INVALID_NUMBER';

  @override
  String get errorInvalidNumberDesc => 'Telefon raqami format xatosi';

  @override
  String get permissionsRequired => 'Ruxsatlar Talab Qilinadi';

  @override
  String get permissionExplanation =>
      'Bu ilova to\'g\'ri ishlashi uchun quyidagi ruxsatlarni talab qiladi:';

  @override
  String get smsPermission => 'SMS Ruxsati';

  @override
  String get smsPermissionDesc => 'Matnli xabarlar yuborish uchun kerak';

  @override
  String get phoneStatePermission => 'Telefon Holati Ruxsati';

  @override
  String get phoneStatePermissionDesc =>
      'SIM kartalarni aniqlash va ikki SIM funksiyasini qo\'llab-quvvatlash uchun kerak';

  @override
  String get privacyNote =>
      'Eslatma: Bu ruxsatlar faqat SMS funksiyasi uchun ishlatiladi va sizning shaxsiy ma\'lumotlaringiz himoyalangan.';

  @override
  String get checkingPermissions => 'Ruxsatlar tekshirilmoqda...';

  @override
  String get permissionStatus => 'Ruxsat Holati';

  @override
  String get whyThesePermissions => 'Nima uchun bu ruxsatlar?';

  @override
  String get smsApp => 'SMS Yuboruvchi Ilovasi';

  @override
  String get defaultNameHeader => 'ism';

  @override
  String get defaultPhoneHeader => 'telefon';
}

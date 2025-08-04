// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'SMS Отправитель Про';

  @override
  String get welcome => 'Добро пожаловать в SMS Отправитель Про!';

  @override
  String get welcomeDescription =>
      'Ваше профессиональное решение для рассылки SMS. Легко отправляйте сообщения множественным контактам.';

  @override
  String get smsServiceReady => 'SMS Сервис Готов';

  @override
  String get smsServiceUnavailable => 'SMS Сервис Недоступен';

  @override
  String get deviceReady => 'Ваше устройство готово к отправке SMS сообщений';

  @override
  String get checkSimCard =>
      'Пожалуйста, проверьте вашу SIM карту и разрешения';

  @override
  String get retryCheck => 'Повторить Проверку';

  @override
  String get quickActions => 'Быстрые Действия';

  @override
  String get testSMS => 'Тест SMS';

  @override
  String get sendTestMessage => 'Отправить тестовое сообщение';

  @override
  String get bulkSMS => 'Массовая SMS';

  @override
  String get sendToMultipleContacts => 'Отправить множественным контактам';

  @override
  String get settings => 'Настройки';

  @override
  String get configureAppSettings => 'Настроить параметры приложения';

  @override
  String get help => 'Помощь';

  @override
  String get troubleshootingGuide => 'Руководство по устранению неполадок';

  @override
  String get keyFeatures => 'Ключевые Функции';

  @override
  String get bulkMessaging => 'Массовая Рассылка';

  @override
  String get bulkMessagingDesc =>
      'Отправляйте SMS множественным контактам из CSV/Excel файлов';

  @override
  String get securePrivate => 'Безопасно и Приватно';

  @override
  String get securePrivateDesc =>
      'Все сообщения отправляются напрямую с вашего устройства';

  @override
  String get dualSimSupport => 'Поддержка Двух SIM';

  @override
  String get dualSimSupportDesc =>
      'Выберите какую SIM карту использовать для отправки';

  @override
  String get progressTracking => 'Отслеживание Прогресса';

  @override
  String get progressTrackingDesc =>
      'Мониторинг прогресса в реальном времени во время массовой отправки';

  @override
  String get home => 'Главная';

  @override
  String get testSMSFunctionality => 'Тест SMS Функциональности';

  @override
  String get testSMSDescription =>
      'Отправьте тестовое сообщение для проверки настроек SMS перед массовой отправкой. Это помогает убедиться, что ваше устройство, SIM карта и разрешения работают правильно.';

  @override
  String get tipTestWithOwnNumber =>
      'Совет: Сначала протестируйте с вашим собственным номером';

  @override
  String get phoneNumber => 'Номер Телефона';

  @override
  String get testPhoneNumber => 'Тестовый Номер Телефона';

  @override
  String get enterPhoneNumber =>
      'Введите номер телефона для тестирования (включая код страны)';

  @override
  String get testMessage => 'Тестовое Сообщение';

  @override
  String get enterTestMessage => 'Введите тестовое сообщение';

  @override
  String get testMessageHint =>
      'Привет! Это тестовое сообщение от SMS Отправитель Про.';

  @override
  String get writeTestMessage =>
      'Напишите короткое тестовое сообщение для проверки SMS функциональности';

  @override
  String get clearAll => 'Очистить Все';

  @override
  String get sendTestMessageBtn => 'Отправить Тестовое Сообщение';

  @override
  String get sendingTest => 'Отправка Теста...';

  @override
  String get pleaseEnterPhoneNumber => 'Пожалуйста, введите номер телефона';

  @override
  String get pleaseEnterMessage => 'Пожалуйста, введите сообщение';

  @override
  String get pleaseEnterTestMessage => 'Пожалуйста, введите тестовое сообщение';

  @override
  String get readyToSendTest => 'Готов к отправке тестового сообщения';

  @override
  String get selectContactFile => 'Выбрать Файл Контактов';

  @override
  String get contactsLoaded => 'контактов загружено';

  @override
  String get readyToSendBulk => 'Готов к массовой отправке сообщений';

  @override
  String get messageContent => 'Содержание Сообщения';

  @override
  String get enterYourMessage => 'Введите ваше сообщение';

  @override
  String get messageHint =>
      'Введите сообщение, которое вы хотите отправить всем контактам...';

  @override
  String get helperText =>
      'Это сообщение будет отправлено всем выбранным контактам';

  @override
  String get clearAllData => 'Очистить Все Данные';

  @override
  String get sendToAllContacts => 'Отправить Всем Контактам';

  @override
  String get sending => 'Отправка...';

  @override
  String get pleaseSelectFile => 'Пожалуйста, сначала выберите файл контактов';

  @override
  String get pleaseEnterMessageToSend =>
      'Пожалуйста, введите сообщение для отправки';

  @override
  String readyToSendToContacts(int count) {
    return 'Готов к отправке $count контактам';
  }

  @override
  String get sendingProgress => 'Прогресс Отправки';

  @override
  String messagesSent(int sent, int total) {
    return 'Отправлено $sent из $total сообщений';
  }

  @override
  String get smsServiceStatus => 'Статус SMS Сервиса';

  @override
  String get smsReady => 'SMS Готов';

  @override
  String get smsNotAvailable => 'SMS Недоступен';

  @override
  String get deviceReadyForSMS =>
      'Ваше устройство готово к отправке SMS сообщений';

  @override
  String get checkSimCardPermissions =>
      'Пожалуйста, проверьте SIM карту, разрешения и поддержку SMS устройством';

  @override
  String get permissions => 'Разрешения';

  @override
  String get simCardSelection => 'Выбор SIM Карты';

  @override
  String get appInformation => 'Информация о Приложении';

  @override
  String get version => 'Версия';

  @override
  String get developer => 'Разработчик';

  @override
  String get platform => 'Платформа';

  @override
  String get smsTeam => 'Команда SMS Отправитель Про';

  @override
  String get androidIOS => 'Android и iOS';

  @override
  String get requestPermissions => 'Запросить Разрешения';

  @override
  String get whyPermissions => 'Зачем эти разрешения?';

  @override
  String get granted => 'Предоставлено';

  @override
  String get denied => 'Отклонено';

  @override
  String get permanentlyDenied => 'Навсегда Отклонено';

  @override
  String get restricted => 'Ограничено';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get smsTroubleshooting => 'Устранение Неполадок SMS';

  @override
  String get troubleshootingIntro => 'Если у вас проблемы с отправкой SMS:';

  @override
  String get simCardIssue => 'SIM Карта';

  @override
  String get simCardDesc =>
      'Убедитесь, что в вашем устройстве установлена активная SIM карта и она правильно распознается.';

  @override
  String get permissionsIssue => 'Разрешения';

  @override
  String get permissionsDesc =>
      'Предоставьте SMS разрешения этому приложению в настройках устройства.';

  @override
  String get networkIssue => 'Сеть';

  @override
  String get networkDesc => 'Убедитесь, что у вас есть покрытие сотовой сети.';

  @override
  String get phoneNumberFormat => 'Номер Телефона';

  @override
  String get phoneNumberDesc =>
      'Проверьте правильность формата номера телефона (включите код страны при необходимости).';

  @override
  String get deviceSupport => 'Поддержка Устройства';

  @override
  String get deviceSupportDesc =>
      'Некоторые эмуляторы или устройства могут не поддерживать SMS функциональность.';

  @override
  String get commonErrorCodes => 'Частые Коды Ошибок:';

  @override
  String get close => 'Закрыть';

  @override
  String get error => 'Ошибка';

  @override
  String get success => 'Успех';

  @override
  String get ok => 'ОК';

  @override
  String get testMessageSentSuccessfully =>
      'Тестовое сообщение успешно отправлено!';

  @override
  String failedToSendTestMessage(String error) {
    return 'Не удалось отправить тестовое сообщение: $error';
  }

  @override
  String messagesSentSuccessfully(int count) {
    return 'Сообщения успешно отправлены $count контактам!';
  }

  @override
  String failedToSendMessages(String error) {
    return 'Не удалось отправить сообщения: $error';
  }

  @override
  String get noFileSelected => 'Файл не выбран';
}

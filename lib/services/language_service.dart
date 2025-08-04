import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _currentLocale = const Locale('uz'); // Default to Uzbek

  Locale get currentLocale => _currentLocale;

  final List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'uz',
      name: 'O\'zbekcha',
      flag: '🇺🇿',
    ),
    LanguageOption(
      code: 'en',
      name: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'ru',
      name: 'Русский',
      flag: '🇷🇺',
    ),
  ];

  void changeLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  LanguageOption get currentLanguageOption {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String flag;

  LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('uz'); // Default to Uzbek
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;

  /// Initialize the service and load saved language preference
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null && _isValidLanguageCode(savedLanguage)) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading preferences, keep the default language
      debugPrint('Error loading language preference: $e');
    } finally {
      _isInitialized = true;
    }
  }

  /// Check if the provided language code is supported
  bool _isValidLanguageCode(String code) {
    return supportedLanguages.any((lang) => lang.code == code);
  }

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
    if (!_isValidLanguageCode(languageCode)) {
      debugPrint('Invalid language code: $languageCode');
      return;
    }
    
    _currentLocale = Locale(languageCode);
    _saveLanguagePreference(languageCode);
    notifyListeners();
  }

  /// Save the language preference to SharedPreferences
  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
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

import 'package:flutter/material.dart';

/// Supported locales for the Samandari app.
/// 
/// This class defines all the locales that the app supports
/// and provides utilities for locale management.
class L10n {
  /// List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('fr', ''), // French
  ];

  /// Get the locale name for display purposes
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get the locale flag emoji for display purposes
  static String getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌐';
    }
  }

  /// Check if a locale is supported
  static bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }

  /// Get the default locale (English)
  static const Locale defaultLocale = Locale('en', '');

  /// Get locale from language code
  static Locale? localeFromLanguageCode(String languageCode) {
    try {
      return supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
      );
    } catch (e) {
      return null;
    }
  }
}

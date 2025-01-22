import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class LocaleProvider extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  Locale _locale = const Locale('it');

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadSavedLocale() async {
    final savedLanguage = await _preferencesService.getLanguage();
    _locale = Locale(savedLanguage);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      await _preferencesService.setLanguage(languageCode);
      notifyListeners();
    }
  }

  // Metodo helper per ottenere il nome della lingua
  String getLanguageName(String code) {
    switch (code) {
      case 'it':
        return 'Italiano';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Italiano';
    }
  }

  // Lista delle lingue supportate
  static const supportedLocales = [
    Locale('it'),
    Locale('en'),
    Locale('es'),
  ];
}

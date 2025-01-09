import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('it');
  final PreferencesService _preferencesService = PreferencesService();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLanguage = await _preferencesService.getLanguage();
    _locale = Locale(savedLanguage);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;
    await _preferencesService.setLanguage(newLocale.languageCode);
    notifyListeners();
  }
}

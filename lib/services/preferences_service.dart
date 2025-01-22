import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class PreferencesService {
  static const String keyRememberMe = 'remember_me';
  static const String keyStoredUser = 'stored_user';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyTutorialSeen = 'tutorial_seen';
  static const String keyQuestsProgress = 'quests_progress';
  static const String keyCompletedQuests = 'completed_quests';
  static const String keyAchievements = 'achievements';
  static const String keyPoints = 'points';
  static const String keyBadges = 'badges';
  static const String keyUserPreferences = 'user_preferences';
  static const String keyExplorationHistory = 'exploration_history';
  static const String keyVisitedLocations = 'visited_locations';
  static const String keyUserStats = 'user_stats';
  static const String keyLanguage = 'app_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyLocationPermission = 'location_permission';
  static const String keyTutorialEnabled = 'tutorial_enabled';
  static const String keyQuestsEnabled = 'quests_enabled';
  static const String keyPhotosEnabled = 'photos_enabled';
  static const String keyAchievementsEnabled = 'achievements_enabled';
  static const String keyUserDataEnabled = 'user_data_enabled';
  static const String keyHighContrastMode = 'high_contrast_mode';
  static const String keyTextSize = 'text_size';
  static const String keyPromotionalNotifications = 'promotional_notifications';
  static const String keyDataConsent = 'data_consent';
  static const String keySystemNotifications = 'system_notifications';
  static const String keyQuestNotifications = 'quest_notifications';
  static const String keyMessageNotifications = 'message_notifications';
  static const String keyDoNotDisturbEnabled = 'do_not_disturb_enabled';
  static const String keyDoNotDisturbStart = 'do_not_disturb_start';
  static const String keyDoNotDisturbEnd = 'do_not_disturb_end';
  static const String keyThemeSync = 'theme_sync_with_system';
  static const String keyFontScale = 'font_scale';
  static const String keyLastBackup = 'last_backup_date';
  static const String keyAccessibilityFeatures = 'accessibility_features';
  static const String keyPrivacySettings = 'privacy_settings';
  static const String keyGuideVersion = 'guide_version';

  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  // Lingua
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, languageCode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLanguage) ?? 'it';
  }

  // Tema
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyThemeMode) ?? 'system';
  }

  // Notifiche
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifications, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotifications) ?? true;
  }

  // Remember Me
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyRememberMe, value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyRememberMe) ?? false;
  }

  // User Storage
  Future<void> storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(keyStoredUser, userJson);
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(keyStoredUser);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userData = jsonDecode(userJson);
      return User.fromJson(userData);
    } catch (e) {
      log('Error decoding stored user: $e');
      await clearStoredUser();
      return null;
    }
  }

  Future<void> clearStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyStoredUser);
  }

  // Onboarding e Tutorial
  Future<void> setTutorialSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTutorialSeen, value);
  }

  Future<bool> getTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyTutorialSeen) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyOnboardingComplete, value);
  }

  Future<bool> getOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyOnboardingComplete) ?? false;
  }

  // Quest Progress
  Future<void> saveQuestProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyQuestsProgress, jsonEncode(progress));
  }

  Future<Map<String, dynamic>?> getQuestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(keyQuestsProgress);
    if (progressJson == null) return null;
    return jsonDecode(progressJson);
  }

  // Achievements
  Future<void> saveAchievements(List<String> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyAchievements, achievements);
  }

  Future<List<String>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyAchievements) ?? [];
  }

  // Points
  Future<void> savePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyPoints, points);
  }

  Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyPoints) ?? 0;
  }

  // Reset functions
  Future<void> resetTutorialAndOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyOnboardingComplete);
    await prefs.remove(keyTutorialSeen);
  }

  Future<void> resetCommunityData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyQuestsProgress);
    await prefs.remove(keyCompletedQuests);
    await prefs.remove(keyAchievements);
    await prefs.remove(keyPoints);
    await prefs.remove(keyBadges);
  }

  Future<void> resetUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserPreferences);
    await prefs.remove(keyExplorationHistory);
    await prefs.remove(keyVisitedLocations);
    await prefs.remove(keyUserStats);
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Rimuove tutte le preferenze
  }

  // Location Permission
  Future<void> setLocationPermission(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLocationPermission, granted);
  }

  Future<bool> getLocationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLocationPermission) ?? false;
  }

  Future<PreferencesData> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesData(
      tutorialEnabled: prefs.getBool(keyTutorialEnabled) ?? true,
      questsEnabled: prefs.getBool(keyQuestsEnabled) ?? true,
      photosEnabled: prefs.getBool(keyPhotosEnabled) ?? true,
      achievementsEnabled: prefs.getBool(keyAchievementsEnabled) ?? true,
      userDataEnabled: prefs.getBool(keyUserDataEnabled) ?? true,
      themeMode: prefs.getString(keyThemeMode) ?? 'system',
      promotionalNotifications: prefs.getBool(keyPromotionalNotifications) ?? true,
      language: prefs.getString(keyLanguage) ?? 'it',
      dataConsent: prefs.getBool(keyDataConsent) ?? false,
    );
  }
  Future<String> checkInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();

  // Controlla se l'onboarding è completo
  final bool onboardingComplete = prefs.getBool(keyOnboardingComplete) ?? false;

  // Controlla se l'utente ha visto il tutorial
  final bool tutorialSeen = prefs.getBool(keyTutorialSeen) ?? false;

  // Controlla se l'utente vuole essere ricordato (Remember Me)
  final bool rememberMe = prefs.getBool(keyRememberMe) ?? false;

  // Logica per determinare la rotta iniziale
  if (!onboardingComplete) {
    return '/onboarding'; // Rotta per l'onboarding
  } else if (!tutorialSeen) {
    return '/tutorial'; // Rotta per il tutorial
  } else if (rememberMe) {
    return '/home'; // Rotta per la home (utente ricordato)
  } else {
    return '/login'; // Rotta per il login
  }
}

  Future<void> updatePreferences({
    required bool tutorialEnabled,
    required bool questsEnabled,
    required bool photosEnabled,
    required bool achievementsEnabled,
    required bool userDataEnabled,
    required String themeMode,
    required bool promotionalNotifications,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTutorialEnabled, tutorialEnabled);
    await prefs.setBool(keyQuestsEnabled, questsEnabled);
    await prefs.setBool(keyPhotosEnabled, photosEnabled);
    await prefs.setBool(keyAchievementsEnabled, achievementsEnabled);
    await prefs.setBool(keyUserDataEnabled, userDataEnabled);
    await prefs.setString(keyThemeMode, themeMode);
    await prefs.setBool(keyPromotionalNotifications, promotionalNotifications);
    await prefs.setString(keyLanguage, language);
  }

  Future<void> setHighContrastMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyHighContrastMode, enabled);
  }

  Future<bool> getHighContrastMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyHighContrastMode) ?? false;
  }

  Future<void> setTextSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyTextSize, size);
  }

  Future<double> getTextSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyTextSize) ?? 16.0; // Dimensione predefinita
  }

  Future<void> setPromotionalNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyPromotionalNotifications, enabled);
  }

  Future<bool> getPromotionalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyPromotionalNotifications) ?? true;
  }

  Future<void> setDataConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDataConsent, consent);
  }

  Future<bool> getDataConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyDataConsent) ?? false;
  }

  Future<void> backupPreferences() async {
    // Implementa la logica per il backup
  }

  Future<void> restorePreferences() async {
    // Implementa la logica per il ripristino
  }

  Future<void> setSystemNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySystemNotifications, enabled);
  }

  Future<bool> getSystemNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keySystemNotifications) ?? true;
  }

  Future<void> setQuestNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyQuestNotifications, enabled);
  }

  Future<bool> getQuestNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyQuestNotifications) ?? true;
  }

  Future<void> setMessageNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyMessageNotifications, enabled);
  }

  Future<bool> getMessageNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyMessageNotifications) ?? true;
  }

  Future<void> setDoNotDisturbEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDoNotDisturbEnabled, enabled);
  }

  Future<bool> getDoNotDisturbEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyDoNotDisturbEnabled) ?? false;
  }

  Future<void> setDoNotDisturbStart(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyDoNotDisturbStart, minutes);
  }

  Future<int?> getDoNotDisturbStart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyDoNotDisturbStart);
  }

  Future<void> setDoNotDisturbEnd(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyDoNotDisturbEnd, minutes);
  }

  Future<int?> getDoNotDisturbEnd() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyDoNotDisturbEnd);
  }

  Future<void> disableDataCollection() async {
    final prefs = await SharedPreferences.getInstance();
    // Disabilita tutte le raccolte dati non essenziali
    await prefs.setBool(keyUserDataEnabled, false);
    await prefs.setBool(keyQuestsEnabled, false);
    await prefs.setBool(keyPhotosEnabled, false);
    await prefs.setBool(keyAchievementsEnabled, false);
  }

  Future<bool> exportUserData(String format) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'personal_info': await getStoredUser(),
        'preferences': await getPreferences(),
        'achievements': await getAchievements(),
        'quests_progress': await getQuestProgress(),
        'points': await getPoints(),
        'visited_locations': prefs.getStringList(keyVisitedLocations),
      };

      if (format == 'json') {
        final jsonData = json.encode(userData);
        // Salva il file JSON
        await _saveJsonFile(jsonData);  // Implementa questo metodo
      } else if (format == 'pdf') {
        // Implementa la generazione del PDF
        await _generatePdfFile(userData);  // Implementa questo metodo
      }

      return true;
    } catch (e) {
      log('Error exporting user data: $e');
      return false;
    }
  }

  Future<void> _saveJsonFile(String jsonData) async {
    // Implementa il salvataggio del file JSON
    // Per esempio:
    // final directory = await getApplicationDocumentsDirectory();
    // final file = File('${directory.path}/user_data.json');
    // await file.writeAsString(jsonData);
  }

  Future<void> _generatePdfFile(Map<String, dynamic> userData) async {
    // Implementa la generazione del PDF
    // Usa un package come pdf o printing per generare il PDF
  }

  Future<bool> deleteUserAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Rimuove tutte le preferenze
      // Implementa la logica per eliminare i dati dal server
      return true;
    } catch (e) {
      log('Error deleting user account: $e');
      return false;
    }
  }

  // Tema e Modalità Scura
  Future<void> updateThemePreferences({
    required String mode,
    required bool syncWithSystem,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(keyThemeMode, mode),
      prefs.setBool(keyThemeSync, syncWithSystem),
    ]);
  }

  Future<ThemePreferences> getThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemePreferences(
      mode: prefs.getString(keyThemeMode) ?? 'system',
      syncWithSystem: prefs.getBool(keyThemeSync) ?? true,
    );
  }

  // Accessibilità
  Future<void> updateAccessibilitySettings({
    required bool highContrast,
    required double textSize,
    Map<String, bool>? additionalFeatures,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(keyHighContrastMode, highContrast),
      prefs.setDouble(keyTextSize, textSize),
      if (additionalFeatures != null)
        prefs.setString(
          keyAccessibilityFeatures,
          json.encode(additionalFeatures),
        ),
    ]);
  }

  Future<AccessibilitySettings> getAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AccessibilitySettings(
      highContrast: prefs.getBool(keyHighContrastMode) ?? false,
      textSize: prefs.getDouble(keyTextSize) ?? 16.0,
      additionalFeatures: _parseAccessibilityFeatures(
        prefs.getString(keyAccessibilityFeatures),
      ),
    );
  }

  Map<String, bool> _parseAccessibilityFeatures(String? jsonString) {
    if (jsonString == null) return {};
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      return data.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      log('Error parsing accessibility features: $e');
      return {};
    }
  }

  // Privacy e Gestione Dati
  Future<void> updatePrivacySettings({
    required bool dataCollection,
    required bool analytics,
    required bool marketing,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'dataCollection': dataCollection,
      'analytics': analytics,
      'marketing': marketing,
    };
    await prefs.setString(keyPrivacySettings, json.encode(settings));
  }

  Future<PrivacySettings> getPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyPrivacySettings);
    final Map<String, dynamic> settings = jsonString != null 
        ? json.decode(jsonString) 
        : {
            'dataCollection': false,
            'analytics': false,
            'marketing': false,
          };
    
    return PrivacySettings.fromJson(settings);
  }

  // Backup e Ripristino
  Future<bool> backupUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupData = {
        'preferences': await getPreferences(),
        'accessibility': await getAccessibilitySettings(),
        'privacy': await getPrivacySettings(),
        'notifications': {
          'enabled': await getNotificationsEnabled(),
          'promotional': await getPromotionalNotifications(),
          'dndEnabled': await getDoNotDisturbEnabled(),
          'dndStart': await getDoNotDisturbStart(),
          'dndEnd': await getDoNotDisturbEnd(),
        },
      };

      // Salva il backup e la data
      await prefs.setString('backup_data', json.encode(backupData));
      await prefs.setInt(keyLastBackup, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      log('Error during backup: $e');
      return false;
    }
  }

  Future<bool> restoreFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupString = prefs.getString('backup_data');
      if (backupString == null) return false;

      final backupData = json.decode(backupString) as Map<String, dynamic>;
      
      // Ripristina i dati dal backup
      await _restoreDataFromBackup(backupData);

      return true;
    } catch (e) {
      log('Error during restore: $e');
      return false;
    }
  }

  Future<void> _restoreDataFromBackup(Map<String, dynamic> backupData) async {
    // Estrai i dati dal backup
    final preferencesData = backupData['preferences'] as Map<String, dynamic>;
    final accessibilityData = backupData['accessibility'] as Map<String, dynamic>;
    final privacyData = backupData['privacy'] as Map<String, dynamic>;
    final notificationsData = backupData['notifications'] as Map<String, dynamic>;

    // Ripristina le preferenze
    await updatePreferences(
      tutorialEnabled: preferencesData['tutorialEnabled'] as bool,
      questsEnabled: preferencesData['questsEnabled'] as bool,
      photosEnabled: preferencesData['photosEnabled'] as bool,
      achievementsEnabled: preferencesData['achievementsEnabled'] as bool,
      userDataEnabled: preferencesData['userDataEnabled'] as bool,
      themeMode: preferencesData['themeMode'] as String,
      promotionalNotifications: preferencesData['promotionalNotifications'] as bool,
      language: preferencesData['language'] as String,
    );

    // Ripristina le impostazioni di accessibilità
    await updateAccessibilitySettings(
      highContrast: accessibilityData['highContrast'] as bool,
      textSize: (accessibilityData['textSize'] as num).toDouble(),
      additionalFeatures: Map<String, bool>.from(
        accessibilityData['additionalFeatures'] as Map,
      ),
    );

    // Ripristina le impostazioni della privacy
    await updatePrivacySettings(
      dataCollection: privacyData['dataCollection'] as bool,
      analytics: privacyData['analytics'] as bool,
      marketing: privacyData['marketing'] as bool,
    );

    // Ripristina le impostazioni delle notifiche
    await setNotificationsEnabled(notificationsData['enabled'] as bool);
    await setPromotionalNotifications(notificationsData['promotional'] as bool);
    await setDoNotDisturbEnabled(notificationsData['dndEnabled'] as bool);
    
    if (notificationsData['dndStart'] != null) {
      await setDoNotDisturbStart(notificationsData['dndStart'] as int);
    }
    if (notificationsData['dndEnd'] != null) {
      await setDoNotDisturbEnd(notificationsData['dndEnd'] as int);
    }
  }

  // Guida Utente
  Future<void> markGuideAsRead(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyGuideVersion, version);
  }

  Future<bool> hasReadGuide(String currentVersion) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyGuideVersion) == currentVersion;
  }

  Future<void> setTutorialEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTutorialEnabled, enabled);
  }

  Future<void> setQuestsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyQuestsEnabled, enabled);
  }

  Future<void> updateAllPreferences(PreferencesData data) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(keyTutorialEnabled, data.tutorialEnabled),
      prefs.setBool(keyQuestsEnabled, data.questsEnabled),
      prefs.setBool(keyPhotosEnabled, data.photosEnabled),
      prefs.setBool(keyAchievementsEnabled, data.achievementsEnabled),
      prefs.setBool(keyUserDataEnabled, data.userDataEnabled),
      prefs.setString(keyThemeMode, data.themeMode),
      prefs.setBool(keyPromotionalNotifications, data.promotionalNotifications),
      prefs.setString(keyLanguage, data.language),
      prefs.setBool(keyDataConsent, data.dataConsent),
    ]);
  }
}

class PreferencesData {
  final bool tutorialEnabled;
  final bool questsEnabled;
  final bool photosEnabled;
  final bool achievementsEnabled;
  final bool userDataEnabled;
  final String themeMode;
  final bool promotionalNotifications;
  final String language;
  final bool dataConsent;

  PreferencesData({
    required this.tutorialEnabled,
    required this.questsEnabled,
    required this.photosEnabled,
    required this.achievementsEnabled,
    required this.userDataEnabled,
    required this.themeMode,
    required this.promotionalNotifications,
    required this.language,
    required this.dataConsent,
  });
}

class ThemePreferences {
  final String mode;
  final bool syncWithSystem;

  ThemePreferences({
    required this.mode,
    required this.syncWithSystem,
  });
}

class AccessibilitySettings {
  final bool highContrast;
  final double textSize;
  final Map<String, bool> additionalFeatures;

  AccessibilitySettings({
    required this.highContrast,
    required this.textSize,
    this.additionalFeatures = const {},
  });
}

class PrivacySettings {
  final bool dataCollection;
  final bool analytics;
  final bool marketing;

  PrivacySettings({
    required this.dataCollection,
    required this.analytics,
    required this.marketing,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      dataCollection: json['dataCollection'] ?? false,
      analytics: json['analytics'] ?? false,
      marketing: json['marketing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'dataCollection': dataCollection,
    'analytics': analytics,
    'marketing': marketing,
  };
}

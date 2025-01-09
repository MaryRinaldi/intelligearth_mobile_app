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
    );
  }

  Future<void> updatePreferences({
    required bool tutorialEnabled,
    required bool questsEnabled,
    required bool photosEnabled,
    required bool achievementsEnabled,
    required bool userDataEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTutorialEnabled, tutorialEnabled);
    await prefs.setBool(keyQuestsEnabled, questsEnabled);
    await prefs.setBool(keyPhotosEnabled, photosEnabled);
    await prefs.setBool(keyAchievementsEnabled, achievementsEnabled);
    await prefs.setBool(keyUserDataEnabled, userDataEnabled);
  }
}

class PreferencesData {
  final bool tutorialEnabled;
  final bool questsEnabled;
  final bool photosEnabled;
  final bool achievementsEnabled;
  final bool userDataEnabled;

  PreferencesData({
    required this.tutorialEnabled,
    required this.questsEnabled,
    required this.photosEnabled,
    required this.achievementsEnabled,
    required this.userDataEnabled,
  });
}

import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/user_profile.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._box);

  static const boxName = 'app_preferences';
  static const _profileKey = 'profile';
  static const _settingsKey = 'settings';

  final Box<dynamic> _box;

  static Future<AppPreferencesRepository> open() async {
    final box = await Hive.openBox<dynamic>(boxName);
    final repository = AppPreferencesRepository(box);

    if (!box.containsKey(_profileKey)) {
      await repository.saveProfile(UserProfile.defaults());
    }
    if (!box.containsKey(_settingsKey)) {
      await repository.saveSettings(AppSettings.defaults());
    }

    return repository;
  }

  Future<UserProfile> loadProfile() async {
    final raw = _box.get(_profileKey);
    if (raw is Map) {
      return UserProfile.fromJson(Map<String, dynamic>.from(raw));
    }
    return UserProfile.defaults();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _box.put(_profileKey, profile.toJson());
  }

  Future<AppSettings> loadSettings() async {
    final raw = _box.get(_settingsKey);
    if (raw is Map) {
      return AppSettings.fromJson(Map<String, dynamic>.from(raw));
    }
    return AppSettings.defaults();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(_settingsKey, settings.toJson());
  }
}

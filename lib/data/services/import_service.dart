import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_settings.dart';
import '../models/dream_entry.dart';
import '../models/user_profile.dart';

class ImportService {
  static const _channel = MethodChannel('dreamlog/share');

  Future<PickedImportFile?> pickJsonFile() async {
    final raw = await _channel.invokeMethod<Object?>('pickJsonFile');
    if (raw == null) {
      return null;
    }
    if (raw is! Map) {
      throw const FormatException('Selected file result was invalid.');
    }
    final data = Map<Object?, Object?>.from(raw);
    final content = data['content']?.toString();
    if (content == null || content.trim().isEmpty) {
      throw const FormatException('Selected file is empty.');
    }
    return PickedImportFile(
      name: data['name']?.toString() ?? 'backup.json',
      content: content,
    );
  }

  DreamBackup parseBackup(String content) {
    final decoded = jsonDecode(content);
    final Object? dreamSource;
    Map<String, dynamic>? profileJson;
    Map<String, dynamic>? settingsJson;
    Map<String, dynamic>? avatarJson;
    final bool isBackupFormat;

    if (decoded is List) {
      dreamSource = decoded;
      isBackupFormat = false;
    } else if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      dreamSource = map['dreams'];
      final rawProfile = map['profile'];
      final rawSettings = map['settings'];
      final rawAvatar = map['avatar'];
      profileJson =
          rawProfile is Map ? Map<String, dynamic>.from(rawProfile) : null;
      settingsJson =
          rawSettings is Map ? Map<String, dynamic>.from(rawSettings) : null;
      avatarJson =
          rawAvatar is Map ? Map<String, dynamic>.from(rawAvatar) : null;
      isBackupFormat = map['format'] == 'dreamlog_backup';
    } else {
      throw const FormatException('Backup JSON must be an object or list.');
    }

    if (dreamSource is! List) {
      throw const FormatException('Backup does not contain a dreams list.');
    }

    final dreamsById = <String, DreamEntry>{};
    var skippedDreams = 0;
    for (final rawDream in dreamSource) {
      try {
        if (rawDream is! Map) {
          skippedDreams++;
          continue;
        }
        final dream = DreamEntry.fromJson(Map<String, dynamic>.from(rawDream));
        dreamsById[dream.id] = dream;
      } catch (_) {
        skippedDreams++;
      }
    }

    if (dreamsById.isEmpty &&
        skippedDreams > 0 &&
        profileJson == null &&
        settingsJson == null) {
      throw const FormatException('No valid DreamLog data found.');
    }

    return DreamBackup(
      dreams: dreamsById.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      profile: profileJson == null ? null : UserProfile.fromJson(profileJson),
      settings:
          settingsJson == null ? null : AppSettings.fromJson(settingsJson),
      avatar: avatarJson == null ? null : BackupAvatar.fromJson(avatarJson),
      skippedDreams: skippedDreams,
      isBackupFormat: isBackupFormat,
    );
  }

  Future<String?> restoreAvatar(BackupAvatar? avatar) async {
    if (avatar == null || avatar.base64.trim().isEmpty) {
      return null;
    }
    final bytes = base64Decode(avatar.base64);
    final dir = await getApplicationDocumentsDirectory();
    final safeExtension = switch (avatar.extension.toLowerCase()) {
      'jpg' || 'jpeg' => 'jpg',
      'webp' => 'webp',
      _ => 'png',
    };
    final file = File(
      '${dir.path}/dreamlog-avatar-${DateTime.now().millisecondsSinceEpoch}.$safeExtension',
    );
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

class PickedImportFile {
  const PickedImportFile({
    required this.name,
    required this.content,
  });

  final String name;
  final String content;
}

class DreamBackup {
  const DreamBackup({
    required this.dreams,
    required this.skippedDreams,
    required this.isBackupFormat,
    this.profile,
    this.settings,
    this.avatar,
  });

  final List<DreamEntry> dreams;
  final UserProfile? profile;
  final AppSettings? settings;
  final BackupAvatar? avatar;
  final int skippedDreams;
  final bool isBackupFormat;
}

class BackupAvatar {
  const BackupAvatar({
    required this.base64,
    required this.extension,
  });

  final String base64;
  final String extension;

  factory BackupAvatar.fromJson(Map<String, dynamic> json) {
    return BackupAvatar(
      base64: json['base64'] as String? ?? '',
      extension: json['extension'] as String? ?? 'png',
    );
  }
}

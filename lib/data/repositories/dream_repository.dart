import 'package:hive_flutter/hive_flutter.dart';

import '../models/dream_entry.dart';

class DreamRepository {
  DreamRepository(this._box);

  static const boxName = 'dream_entries';
  static const _legacySeedIds = {
    'dream-ocean',
    'dream-glass-city',
    'dream-golden-parade',
    'dream-hallway',
  };

  final Box<dynamic> _box;

  static Future<DreamRepository> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>(boxName);
    final repository = DreamRepository(box);
    await repository.removeLegacySeedData();
    return repository;
  }

  Future<List<DreamEntry>> all() async {
    final entries = _box.values
        .whereType<Map>()
        .map((raw) => DreamEntry.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<DreamEntry?> byId(String id) async {
    final raw = _box.get(id);
    if (raw is! Map) {
      return null;
    }
    return DreamEntry.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> save(DreamEntry entry) async {
    await _box.put(entry.id, entry.toJson());
  }

  Future<void> saveAll(
    List<DreamEntry> entries, {
    required bool replace,
  }) async {
    if (replace) {
      await _box.clear();
    }
    for (final entry in entries) {
      await save(entry);
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleBookmark(String id) async {
    final entry = await byId(id);
    if (entry == null) {
      return;
    }
    await save(entry.copyWith(isBookmarked: !entry.isBookmarked));
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> removeLegacySeedData() async {
    for (final id in _legacySeedIds) {
      await _box.delete(id);
    }
  }
}

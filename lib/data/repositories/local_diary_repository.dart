import 'package:hive/hive.dart';

import '../../domain/models/diary_entry.dart';
import '../../domain/models/recommendation_result.dart';
import '../../domain/repositories/diary_repository.dart';

class LocalDiaryRepository implements DiaryRepository {
  static const String boxName = 'diary';

  Box<DiaryEntry> get _box => Hive.box<DiaryEntry>(boxName);

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<DiaryEntry?> getByDate(DateTime date) async {
    try {
      final target = _dateOnly(date);

      for (final entry in _box.values) {
        if (_dateOnly(entry.date) == target) {
          return entry;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get diary by date: $e');
    }
  }

  @override
  Future<List<DiaryEntry>> listAll({bool newestFirst = true}) async {
    try {
      final list = _box.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return newestFirst ? list.reversed.toList() : list;
    } catch (e) {
      throw Exception('Failed to list diary entries: $e');
    }
  }

  @override
  Future<DiaryEntry> upsertForDate({
    required DateTime date,
    required String content,
  }) async {
    try {
      final now = DateTime.now();
      final d = _dateOnly(date);

      final existing = await getByDate(d);

      if (existing == null) {
        final entry = DiaryEntry(
          id: 'entry-${d.toIso8601String()}',
          date: d,
          content: content,
          createdAt: now,
          updatedAt: now,
        );

        await _box.put(entry.id, entry);
        return entry;
      } else {
        final updated = DiaryEntry(
          id: existing.id,
          date: existing.date,
          content: content,
          createdAt: existing.createdAt,
          updatedAt: now,
          recommendedSongId: existing.recommendedSongId,
          recommendation: existing.recommendation,
        );

        await _box.put(updated.id, updated);
        return updated;
      }
    } catch (e) {
      throw Exception('Failed to upsert diary entry: $e');
    }
  }

  @override
  Future<void> attachRecommendation({
    required String diaryEntryId,
    required RecommendationResult recommendation,
  }) async {
    try {
      final entry = _box.get(diaryEntryId);

      if (entry == null) return;

      final updated = DiaryEntry(
        id: entry.id,
        date: entry.date,
        content: entry.content,
        createdAt: entry.createdAt,
        updatedAt: DateTime.now(),
        recommendedSongId: recommendation.songId,
        recommendation: recommendation,
      );

      await _box.put(updated.id, updated);
    } catch (e) {
      throw Exception('Failed to attach recommendation: $e');
    }
  }
}

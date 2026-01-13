import 'package:hive/hive.dart';

import '../../domain/models/diary_entry.dart';
import '../../domain/models/recommendation_result.dart';
import '../../domain/repositories/diary_repository.dart';

class LocalDiaryRepository implements DiaryRepository {
  final Box<DiaryEntry> _box = Hive.box<DiaryEntry>('diary');

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<DiaryEntry?> getByDate(DateTime date) async {
    final d = _dateOnly(date);
    try {
      return _box.values.firstWhere(
        (e) => _dateOnly(e.date) == d,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DiaryEntry>> listAll({bool newestFirst = true}) async {
    final list = _box.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return newestFirst ? list.reversed.toList() : list;
  }

  @override
  Future<DiaryEntry> upsertForDate({
    required DateTime date,
    required String content,
  }) async {
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
  }

  @override
  Future<void> attachRecommendation({
    required String diaryEntryId,
    required RecommendationResult recommendation,
  }) async {
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
  }
}

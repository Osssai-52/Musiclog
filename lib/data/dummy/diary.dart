import '../../domain/models/diary_entry.dart';
import '../../domain/models/recommendation_result.dart';
import '../../domain/repositories/diary_repository.dart';

class DummyDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = [];

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Future<DiaryEntry?> getByDate(DateTime date) async {
    final d = _dateOnly(date);
    for (final e in _entries) {
      if (_dateOnly(e.date) == d) return e;
    }
    return null;
  }

  @override
  Future<List<DiaryEntry>> listAll({bool newestFirst = true}) async {
    final copy = [..._entries];
    copy.sort((a, b) => a.date.compareTo(b.date));
    if (newestFirst) copy.reversed.toList();
    return List.unmodifiable(newestFirst ? copy.reversed.toList() : copy);
  }

  @override
  Future<DiaryEntry> upsertForDate({
    required DateTime date,
    required String content,
  }) async {
    final now = DateTime.now();
    final d = _dateOnly(date);

    final existingIndex = _entries.indexWhere((e) => _dateOnly(e.date) == d);

    if (existingIndex == -1) {
      final entry = DiaryEntry(
        id: 'entry-${d.toIso8601String()}',
        date: d,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      _entries.add(entry);
      return entry;
    } else {
      final prev = _entries[existingIndex];
      final updated = DiaryEntry(
        id: prev.id,
        date: prev.date,
        content: content,
        createdAt: prev.createdAt,
        updatedAt: now,
        recommendedSongId: prev.recommendedSongId,
        recommendation: prev.recommendation,
      );
      _entries[existingIndex] = updated;
      return updated;
    }
  }

  @override
  Future<void> attachRecommendation({
    required String diaryEntryId,
    required RecommendationResult recommendation,
  }) async {
    final idx = _entries.indexWhere((e) => e.id == diaryEntryId);
    if (idx == -1) return;

    final prev = _entries[idx];
    final updated = DiaryEntry(
      id: prev.id,
      date: prev.date,
      content: prev.content,
      createdAt: prev.createdAt,
      updatedAt: DateTime.now(),
      recommendedSongId: recommendation.songId,
      recommendation: recommendation,
    );
    _entries[idx] = updated;
  }
}
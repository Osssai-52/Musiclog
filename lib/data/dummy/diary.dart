import '../../domain/models/diary_entry.dart';
import '../../domain/models/recommendation_result.dart';
import '../../domain/repositories/diary_repository.dart';

class DummyDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = [];

  DummyDiaryRepository() {
    _initializeDummyData();
  }

  void _initializeDummyData() {
    _entries.addAll([
      DiaryEntry(
        id: 'entry-1',
        date: DateTime(2026, 1, 1),
        content: '오늘은 정말 좋은 날씨였다. 산책을 나갔는데 날씨가 정말 좋았다.',
        createdAt: DateTime(2026, 1, 1, 10, 0),
        updatedAt: DateTime(2026, 1, 1, 10, 0),
        recommendedSongId: 'KRNAR2308242',
        recommendation: RecommendationResult(
          diaryEntryId: 'entry-1',
          songId: 'KRNAR2308242',
          reason: '밝고 긍정적인 가사가 일기의 기분과 맞습니다',
          matchedLines: ['그럼에도 불구하고, 나는 너를 용서하고'],
          generatedAt: DateTime(2026, 1, 1, 10, 30),
          model: 'GPT-4',
          confidence: 0.92,
        ),
      ),
      DiaryEntry(
        id: 'entry-2',
        date: DateTime(2026, 1, 10),
        content: '새해를 맞이하며 새로운 목표를 세웠다. 올해는 더 열심히 하자.',
        createdAt: DateTime(2026, 1, 10, 14, 0),
        updatedAt: DateTime(2026, 1, 10, 14, 0),
        recommendedSongId: 'KRA382100429',
        recommendation: RecommendationResult(
          diaryEntryId: 'entry-2',
          songId: 'KRA382100429',
          reason: '새로운 시작에 대한 희망이 담긴 곡입니다',
          matchedLines: ['그대 작은 나의 세상이 되어'],
          generatedAt: DateTime(2026, 1, 10, 14, 30),
          model: 'GPT-4',
          confidence: 0.87,
        ),
      ),
      DiaryEntry(
        id: 'entry-3',
        date: DateTime(2025, 12, 25),
        content: '크리스마스! 친구들과 함께 보냈다. 정말 행복한 하루였다.',
        createdAt: DateTime(2025, 12, 25, 18, 0),
        updatedAt: DateTime(2025, 12, 25, 18, 0),
        recommendedSongId: 'KRA490700223',
        recommendation: RecommendationResult(
          diaryEntryId: 'entry-3',
          songId: 'KRA490700223',
          reason: '감성적이고 감동적인 곡이 어울립니다',
          matchedLines: ['아무도 내 맘을 모르죠'],
          generatedAt: DateTime(2025, 12, 25, 18, 30),
          model: 'GPT-4',
          confidence: 0.89,
        ),
      ),
      DiaryEntry(
        id: 'entry-4',
        date: DateTime(2025, 12, 20),
        content: '연말이 다가왔다. 올해를 되돌아본다. 좋은 일도 많았고 힘든 일도 있었다.',
        createdAt: DateTime(2025, 12, 20, 20, 0),
        updatedAt: DateTime(2025, 12, 20, 20, 0),
        recommendedSongId: 'KRMIM2540757',
        recommendation: RecommendationResult(
          diaryEntryId: 'entry-4',
          songId: 'KRMIM2540757',
          reason: '복잡한 감정을 표현하는 곡입니다',
          matchedLines: ['난 널 버리지 않아'],
          generatedAt: DateTime(2025, 12, 20, 20, 30),
          model: 'GPT-4',
          confidence: 0.85,
        ),
      ),
      DiaryEntry(
        id: 'entry-5',
        date: DateTime(2025, 12, 5),
        content: '겨울이 정말 추워졌다. 따뜻한 음료를 마시며 책을 읽었다.',
        createdAt: DateTime(2025, 12, 5, 15, 0),
        updatedAt: DateTime(2025, 12, 5, 15, 0),
        recommendedSongId: 'USA2P2551249',
        recommendation: RecommendationResult(
          diaryEntryId: 'entry-5',
          songId: 'USA2P2551249',
          reason: '차분하고 편안한 감정의 곡입니다',
          matchedLines: ['I\'m not cute anymore'],
          generatedAt: DateTime(2025, 12, 5, 15, 30),
          model: 'GPT-4',
          confidence: 0.83,
        ),
      ),
      DiaryEntry(
        id: 'entry-6',
        date: DateTime(2025, 11, 30),
        content: '11월이 끝났다. 새로운 달이 시작된다. 더 열심히 하자.',
        createdAt: DateTime(2025, 11, 30, 23, 0),
        updatedAt: DateTime(2025, 11, 30, 23, 0),
        recommendedSongId: 'KRA302500475',
        recommendation: RecommendationResult(
          diaryEntryId: 'entry-6',
          songId: 'KRA302500475',
          reason: '집중력과 목표를 다루는 곡입니다',
          matchedLines: ['I cannot focus on anything but you'],
          generatedAt: DateTime(2025, 11, 30, 23, 30),
          model: 'GPT-4',
          confidence: 0.88,
        ),
      ),
      DiaryEntry(
        id: 'entry-7',
        date: DateTime(2025, 11, 15),
        content: '감정이 복잡한 하루였다. 이별에 대해 생각해본다.',
        createdAt: DateTime(2025, 11, 15, 19, 0),
        updatedAt: DateTime(2025, 11, 15, 19, 0),
        recommendedSongId: 'KRA382506038',
        recommendation: RecommendationResult(
          diaryEntryId: 'entry-7',
          songId: 'KRA382506038',
          reason: '이별의 감정을 표현하는 곡입니다',
          matchedLines: ['안녕은 우릴 아프게 하지만 우아할 거야'],
          generatedAt: DateTime(2025, 11, 15, 19, 30),
          model: 'GPT-4',
          confidence: 0.90,
        ),
      ),
    ]);
  }

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
    if (newestFirst){
      return List.unmodifiable(copy.reversed.toList());
    } else{
      return List.unmodifiable(copy);
    }
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

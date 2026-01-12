import '../models/diary_entry.dart';

abstract class DiaryRepository {
    Future<DiaryEntry?> getByDate(DateTime date);
    Future<List<DiaryEntry>> listAll({bool newestFirst = true});

    Future<DiaryEntry> upsetForDate({
        required DateTime date,
        required String content,
    });

    Future<void> attachRecommendation({
        required String diaryEntryId,
        required RecommendationResult recommendation,
    });
}
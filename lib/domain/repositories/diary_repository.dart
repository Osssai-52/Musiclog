import 'package:musiclog/domain/models/diary_entry.dart';
import 'package:musiclog/domain/models/recommendation_result.dart';

abstract class DiaryRepository {
  Future<DiaryEntry?> getByDate(DateTime date);
  Future<List<DiaryEntry>> listAll({bool newestFirst = true});
  Future<DiaryEntry> upsertForDate({
    required String diaryEntryId,
    required RecommendationResult recommendation,
});
  Future<void> attachRecommendation({
    required String diaryEntryId,
    required RecommendationResult recommendation,
});
}
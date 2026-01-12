
import '../models/diary_entry.dart';

abstract class DiaryRepository {
    Future<DiaryEntry?> getByDate(DateTime date);
    
    Future<DiaryEntry> upsertForDate({
        required DateTime date,
        required String content,
    });

    Future<void> attachRecommendation({
        required String diaryEntryId,
        required String songId,
    });
}

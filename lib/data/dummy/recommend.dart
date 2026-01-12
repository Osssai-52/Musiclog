import '../../domain/models/recommend_request.dart';
import '../../domain/models/recommendation_result.dart';
import '../../domain/services/recommend_service.dart';

class DummyRecommendService implements RecommendService {
  int _cursor = 0;

  @override
  Future<RecommendationResult> recommend({
    required String diaryEntryId,
    required RecommendRequest request,
  }) async {
    final candidates = request.catalog
        .where((s) => !request.excludedSongIds.contains(s.id))
        .toList();

    if (candidates.isEmpty) {
      throw StateError('No available songs (all excluded).');
    }

    final picked = candidates[_cursor % candidates.length];
    _cursor++;

    await Future.delayed(const Duration(milliseconds: 700));

    return RecommendationResult(
      diaryEntryId: diaryEntryId,
      songId: picked.id,
      reason: '일기 내용의 분위기와 감정선을 반영해 이 곡을 추천했어요.',
      matchedLines: [
        picked.lyricsSnippet ?? '...',
      ],
      generatedAt: DateTime.now(),
      model: 'dummy',
      confidence: 0.8,
    );
  }
}
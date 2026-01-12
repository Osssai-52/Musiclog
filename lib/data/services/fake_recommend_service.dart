import '../../domain/services/recommend_service.dart';
import '../../domain/services/recommend_request.dart';
import '../../domain/models/recommendation_result.dart';

class FakeRecommendService implements RecommendService {
    @override
    Future<RecommendationResult> recommend({
        required String diaryEntryId,
        required RecommendRequest request,
    }) async {
        final availableSongs = request.catalog
            .where((s) => !request.excludedSongIds.contains(s.id))
            .toList();

        if (availableSongs.isEmpty) {
            throw Exception('No available songs to recommend');
        }

        final song = availableSongs.first;

        return RecommendationResult(
            diaryEntryId: diaryEntryId,
            songId: song.id,
            reason: "오늘 일기의 감정과 분위기에 잘 어울리는 곡이에요.",
            matchedLines: const [],
            generatedAt: DateTime.now(),
            model: 'fake',
        );
    }
}

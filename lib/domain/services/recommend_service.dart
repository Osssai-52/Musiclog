import 'recommend_request.dart';
import '../models/recommendation_result.dart';

abstract class RecommendService {
    Future<RecommendationResult> recommend({
        required String diaryEntryId,
        required RecommendRequest request,
    });
}


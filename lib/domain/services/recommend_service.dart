import 'package:musiclog/domain/models/recommendation_result.dart';

import '../models/recommend_request.dart';

abstract class RecommendService {
  Future<RecommendationResult> recommend({
    required String diaryEntryId,
    required RecommendRequest request,
});
}
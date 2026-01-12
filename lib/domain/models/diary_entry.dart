import 'package:musiclog/domain/models/recommendation_result.dart';

class DiaryEntry {
  final String id; //UUID
  final DateTime date; // 로컬 기준 yyyy-mm-dd
  final String content; //일기 본문
  final DateTime createdAt;
  final DateTime updatedAt;

  // 추천 결과(확정된 곡)
  final String? recommendedSongId;
  final RecommendationResult? recommendation;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.recommendedSongId,
    this.recommendation,
  });
}
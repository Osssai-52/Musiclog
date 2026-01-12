import 'package:musiclog/domain/models/recommendation_result.dart';

class DiaryEntry {
  final String id;
  final DateTime date;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

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
import 'package:hive/hive.dart';

part 'recommendation_result.g.dart';

@HiveType(typeId: 2)
class RecommendationResult {
  @HiveField(0)
  final String diaryEntryId;

  @HiveField(1)
  final String songId;

  @HiveField(2)
  final String reason;

  @HiveField(3)
  final List<String> matchedLines;

  @HiveField(4)
  final DateTime generatedAt;

  @HiveField(5)
  final String model;

  @HiveField(6)
  final double? confidence;

  RecommendationResult({
    required this.diaryEntryId,
    required this.songId,
    required this.reason,
    required this.matchedLines,
    required this.generatedAt,
    required this.model,
    this.confidence,
  });
}

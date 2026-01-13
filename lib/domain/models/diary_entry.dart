import 'package:hive/hive.dart';
import 'package:musiclog/domain/models/recommendation_result.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 1)
class DiaryEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final String? recommendedSongId;

  @HiveField(6)
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

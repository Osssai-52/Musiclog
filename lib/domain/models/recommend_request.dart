import 'package:musiclog/domain/models/recommendation_result.dart';
import 'song.dart';

class RecommendRequest {
  final String diaryText;
  final List<Song> catalog;
  final Set<String> excludedSongIds;
  final String? mood;

  RecommendRequest({
    required this.diaryText,
    required this.catalog,
    required this.excludedSongIds,
    this.mood,
  });
}
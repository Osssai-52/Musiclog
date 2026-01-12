import '../models/song.dart';

class RecommendRequest {
  final String diaryText;
  final List<Song> catalog;          // Top100 메타(+가능하면 lyricsSnippet)
  final Set<String> excludedSongIds; // 중복 방지
  final String? mood;

  RecommendRequest({
    required this.diaryText,
    required this.catalog,
    required this.excludedSongIds,
    this.mood,
  });
}


import '../models/song.dart';

class RecommendRequest {
    final String diaryText;
    final List<Song> catalog;
    final Set<String> excludedSongIds;

    RecommendRequest({
        required this.diaryText,
        required this.catalog,
        required this.excludedSongIds,
    });
}


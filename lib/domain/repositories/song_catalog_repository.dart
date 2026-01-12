import '../models/song.dart';

abstract class SongCatalogRepository {
  /// API에서 Top 100 노래 목록을 가져옵니다
  Future<List<Song>> getTopSongs();

  /// ID로 특정 노래를 조회합니다 (캐시에서)
  Future<Song?> getById(String id);
}

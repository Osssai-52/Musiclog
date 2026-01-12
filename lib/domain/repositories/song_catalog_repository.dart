import 'package:musiclog/domain/models/song.dart';

abstract class SongCatalogRepository {
  Future<void> init(); // 기존 유지: assets 대신 Apple API 캐시 초기화로 사용
  Future<Song?> getById(String id);
  Future<List<Song>> getTopSongs(); // Top100 전체(캐시 기반 권장)
}

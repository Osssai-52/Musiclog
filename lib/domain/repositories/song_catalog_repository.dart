import 'package:musiclog/domain/models/song.dart';

abstract class SongCatalogRepository {
  Future<void> init();
  Future<Song?> getById(String id);
  Future<List<Song>> getTopSongs();
}

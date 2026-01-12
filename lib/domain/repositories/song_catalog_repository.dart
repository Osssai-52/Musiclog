import '../models/song.dart';

abstract class SongCatalogRepository {
    Future<void> init();
    Future<List<Song>> getAll();
}

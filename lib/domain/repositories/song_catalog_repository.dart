import '../models/song.dart';

abstract class SongCatalogRepository {
    Future<List<Song>> getAll();
}


import '../../domain/models/song.dart';
import '../../domain/repositories/song_catalog_repository.dart';
import '../datasources/song_remote_data_source.dart';
import '../dtos/song_dto.dart';
import '../mappers/song_mapper.dart';

class SongCatalogRepositoryImpl implements SongCatalogRepository {
  final SongRemoteDataSource remoteDataSource;
  List<Song>? _cachedSongs;

  SongCatalogRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Song>> getTopSongs() async {
    if (_cachedSongs != null) {
      return _cachedSongs!;
    }

    final List<SongDto> dtoList = await remoteDataSource.fetchTopSongs();
    _cachedSongs = dtoList.map((dto) => dto.toDomain()).toList();

    return _cachedSongs!;
  }

  @override
  Future<Song?> getById(String id) async {
    _cachedSongs ??= await getTopSongs();

    try {
      return _cachedSongs!.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }
}

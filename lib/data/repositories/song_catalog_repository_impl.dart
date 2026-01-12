import '../../domain/models/song.dart';
import '../../domain/repositories/song_catalog_repository.dart';
import '../datasources/song_remote_data_source.dart';
import '../detos/song_dto.dart';
import '../mappers/song_mapper.dart';

class SongCatalogRepositoryImpl implements SongCatalogRepository {
  final SongRemoteDataSource remoteDataSource;

  SongCatalogRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Song>> getAll() async {
    final List<SongDto> dtoList =
        await remoteDataSource.fetchSongs();

    return dtoList
        .map((dto) => dto.toDomain())
        .toList();
  }
}

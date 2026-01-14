import '../dtos/song_dto.dart';

abstract class SongRemoteDataSource {
  Future<List<SongDto>> fetchTopSongs();
}
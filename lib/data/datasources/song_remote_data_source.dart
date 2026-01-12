import '../detos/song_dto.dart';

abstract class SongRemoteDataSource {
    Future<List<SongDto>> fetchSongs();
}

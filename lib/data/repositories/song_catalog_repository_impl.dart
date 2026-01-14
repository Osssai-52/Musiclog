import '../../domain/models/song.dart';
import '../../domain/repositories/song_catalog_repository.dart';
import '../datasources/song_remote_data_source.dart';
import '../../utils/lyrics_snippet_extractor.dart';

class SongCatalogRepositoryImpl implements SongCatalogRepository {
  final SongRemoteDataSource remote;

  List<Song>? _cache;
  final Map<String, Song> _byId = {};

  SongCatalogRepositoryImpl(this.remote);

  @override
  Future<List<Song>> getTopSongs() async {
    if (_cache != null) return _cache!;

    final dtos = await remote.fetchTopSongs();

    final songs = dtos.map((dto) {
      final rebuiltSnippet = buildLyricsSnippetFromFull(dto.lyricsFull, maxLines: 10);

      final song = Song(
        id: dto.id,
        title: dto.title,
        artist: dto.artist,
        album: dto.album,
        year: dto.year,
        coverUrl: dto.coverUrl,
        coverLocalPath: dto.coverLocalPath,
        lyricsFull: dto.lyricsFull, // 유지
        lyricsSnippet: rebuiltSnippet.isNotEmpty ? rebuiltSnippet : (dto.lyricsSnippet ?? ''),
        appleMusicUrl: dto.appleMusicUrl,
        previewUrl: dto.previewUrl,
      );

      _byId[song.id] = song;
      return song;
    }).toList();

    _cache = songs;
    return songs;
  }

  @override
  Future<Song?> getById(String id) async {
    if (_cache == null) {
      await getTopSongs();
    }
    return _byId[id];
  }
}
import '../../domain/models/song.dart';
import '../dtos/song_dto.dart';

extension SongDtoMapper on SongDto {
Song toDomain() {
  return Song(
    id: id,
    title: title,
    artist: artist,
    album: album,
    year: year,
    coverUrl: coverUrl,
    coverLocalPath: coverLocalPath,
    lyricsFull: lyricsFull,
    lyricsSnippet: lyricsSnippet,
    appleMusicUrl: appleMusicUrl,
    previewUrl: previewUrl,
  );
}
}


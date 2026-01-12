import '../../domain/models/song.dart';
import '../detos/song_dto.dart';

extension SongDtoMapper on SongDto {
    Song toDomain() {
        return Song(
            id: id,
            title: title,
            artist: artist,
            lyrics: lyricsFull ?? '',
        );
    }
}


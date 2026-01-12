import '../../domain/models/song.dart';
import '../detos/song_dto.dart';

extension SongMapper on SongDto {
    Song toDomain() {
        return Song(
            id: id,
            title: title,
            artist: artist,
            lyricsFull: lyricsFull,
        );
    }
}


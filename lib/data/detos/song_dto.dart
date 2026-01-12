class SongDto {
    final String id;
    final String title;
    final String artist;
    final String lyricsFull;

    SongDto({
        required this.id,
        required this.title,
        required this.artist,
        required this.lyricsFull,
    });

    factory SongDto.fromJson(Map<String, dynamic> json) {
        return SongDto(
            id: json['id'] as String,
            title: json['title'] as String,
            artist: json['artist'] as String,
            lyricsFull: json['lyricsFull'] as String,
        );
    }
}

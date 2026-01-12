class SongDto {
    final String id;
    final String title;
    final String artist;
    final String? lyricsFull; // 가사는 보통 없음 → nullable

    SongDto({
        required this.id,
        required this.title,
        required this.artist,
        this.lyricsFull,
    });

    factory SongDto.fromJson(Map<String, dynamic> json) {
        return SongDto(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        artist: json['artist']?.toString() ?? '',
        lyricsFull: json['lyricsFull']?.toString(),
        );
    }
}

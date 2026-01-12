class SongDto {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final int? year;
  final String? coverUrl;
  final String? coverLocalPath;
  final String? lyricsFull;
  final String? lyricsSnippet;
  final String? appleMusicUrl;
  final String? previewUrl;

  SongDto({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.year,
    this.coverUrl,
    this.coverLocalPath,
    this.lyricsFull,
    this.lyricsSnippet,
    this.appleMusicUrl,
    this.previewUrl,
  });

  factory SongDto.fromJson(Map<String, dynamic> json) {
    return SongDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      album: json['album']?.toString(),
      year: json['year'] is int
          ? json['year'] as int
          : int.tryParse(json['year']?.toString() ?? ''),
      coverUrl: json['coverUrl']?.toString(),
      coverLocalPath: json['coverLocalPath']?.toString(),
      lyricsFull: json['lyricsFull']?.toString(),
      lyricsSnippet: json['lyricsSnippet']?.toString(),
      appleMusicUrl: json['appleMusicUrl']?.toString(),
      previewUrl: json['previewUrl']?.toString(),
    );
  }
}

class Song{
  final String id; //ISRC id
  final String title;
  final String artist;
  final String? album;
  final int? year;

  final String? coverUrl;
  final String? coverLocalPath;

  final String? lyricsFull;
  final String? lyricsSnippet;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.year,
    this.coverUrl,
    this.coverLocalPath,
    this.lyricsFull,
    this.lyricsSnippet,
  });
}
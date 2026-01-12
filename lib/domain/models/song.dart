class Song {
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
        this.appleMusicUrl,
        this.previewUrl,
    });
}

import 'package:musiclog/domain/repositories/song_catalog_repository.dart';

import '../../domain/models/song.dart';

class DummySongCatalogRepository implements SongCatalogRepository{
  bool _inited = false;

  final List<Song> _songs = [
    Song(
      id: 's1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      album: 'After Hours',
      year: 2019,
      coverUrl: 'https://picsum.photos/300?1',
      lyricsSnippet: 'I said, ooh, I\'m blinded by the lights...',
    ),
    Song(
      id: 's2',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      album: '÷ (Divide)',
      year: 2017,
      coverUrl: 'https://picsum.photos/300?2',
      lyricsSnippet: 'I\'m in love with the shape of you...',
    ),
    Song(
      id: 's3',
      title: 'Someone Like You',
      artist: 'Adele',
      album: '21',
      year: 2011,
      coverUrl: 'https://picsum.photos/300?3',
      lyricsSnippet: 'Never mind, I\'ll find someone like you...',
    ),
  ];

  @override
  Future<void> init() async {
    _inited = true;
  }

  void _ensureInit() {
    if(!_inited){
      throw StateError('SongCatalogRepository.init() must be called first');
    }
  }

  @override
  Future<Song?> getById(String id) async {
    _ensureInit()
        try {
          return _songs.firstWhere((s) => s.id == id);
        } catch (_) {
          return null;
        }
  }

  @override
  Future<List<Song>> getTopSongs() async {
    _ensureInit();
    return List.unmodifiable(_songs);
  }
}
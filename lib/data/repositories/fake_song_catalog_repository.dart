import '../../domain/repositories/song_catalog_repository.dart';
import '../../domain/models/song.dart';

class FakeSongCatalogRepository implements SongCatalogRepository {
    @override
    Future<void> init() async {}

    @override
    Future<Song?> getById(String id) async => null;

    @override
    Future<List<Song>> getAll() async {
        return [
            Song(id: 'song1', title: 'Fix you', artist: 'Coldplay'),
            Song(id: 'song2', title: 'Imagine', artist: 'John Lennon'),
        ];
    }

    @override
    Future<List<Song>> getTopSongs() async {
        return [
            Song(id: 'song1', title: 'Fix you', artist: 'Coldplay'),
            Song(id: 'song2', title: 'Imagine', artist: 'John Lennon'),
        ];
    }
}


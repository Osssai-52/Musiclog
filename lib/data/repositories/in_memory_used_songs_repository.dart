import '../../domain/repositories/used_songs_repository.dart';

class InMemoryUsedSongsRepository implements UsedSongsRepository {
    final Set<String> _used = {};

    @override
    Future<Set<String>> getUsedSongIds() async {
        return _used;
    }

    @override
    Future<void> markUsed(String songId) async {
        _used.add(songId);
    }
}

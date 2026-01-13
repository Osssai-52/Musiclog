class LocalUsedSongsRepository implements UsedSongsRepository {
  final Box _box = Hive.box('used_songs');

  @override
  Future<Set<String>> getUsedSongIds() async {
    return Set<String>.from(_box.get('used', defaultValue: <String>[]));
  }

  @override
  Future<void> markUsed(String songId) async {
    final set = await getUsedSongIds();
    set.add(songId);
    await _box.put('used', set.toList());
  }
}

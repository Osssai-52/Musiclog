abstract class UsedSongsRepository {
  Future<Set<String>> getUsedSongIds();
  Future<void> markUsed(String songId);
  Future<void> clearAll();
}
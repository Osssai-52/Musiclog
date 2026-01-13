import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/used_songs_repository.dart';

class UsedSongsRepositoryPrefs implements UsedSongsRepository {
  static const String _key = 'used_song_ids';

  @override
  Future<Set<String>> getUsedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    return list.toSet();
  }

  @override
  Future<void> markUsed(String songId) async {
    if (songId == 'NONE') return;

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];

    if (!list.contains(songId)) {
      list.add(songId);
      await prefs.setStringList(_key, list);
    }
  }
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
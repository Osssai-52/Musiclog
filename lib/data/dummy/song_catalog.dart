import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:musiclog/domain/repositories/song_catalog_repository.dart';
import '../../domain/models/song.dart';

class DummySongCatalogRepository implements SongCatalogRepository {
  bool _inited = false;
  final List<Song> _songs = [];

  @override
  Future<void> init() async {
    try {
      // assets/songs.json 파일 로드
      final jsonString = await rootBundle.loadString('assets/songs.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final songsList = jsonData['data'] as List<dynamic>;

      _songs.addAll(
        songsList.map((song) => Song(
          id: song['id'] as String,
          title: song['title'] as String,
          artist: song['artist'] as String,
          album: song['album'] as String?,
          year: song['year'] as int?,
          coverUrl: song['coverUrl'] as String?,
          lyricsSnippet: song['lyricsSnippet'] as String?,
          lyricsFull: song['lyricsFull'] as String?,
        )),
      );

      _inited = true;
    } catch (e) {
      print('Error loading songs: $e');
      _inited = true; // 에러 발생해도 계속 진행
    }
  }

  void _ensureInit() {
    if (!_inited) {
      throw StateError('SongCatalogRepository.init() must be called first');
    }
  }

  @override
  Future<Song?> getById(String id) async {
    _ensureInit();
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

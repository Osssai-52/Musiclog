import '../models/song.dart';
import '../models/recommendation_result.dart';
import '../services/recommend_request.dart';
import '../repositories/song_catalog_repository.dart';
import '../repositories/used_songs_repository.dart';
import '../services/recommend_service.dart';
import '../../data/services/openai_embeddings_service.dart';
import '../../utils/vector_math.dart';

class RecommendSongUseCase {
  final RecommendService recommendService;
  final UsedSongsRepository usedSongsRepository;
  final SongCatalogRepository songCatalogRepository;
  final OpenAiEmbeddingsService embeddingsService;

  List<Map<String, dynamic>> _lastTop10Scores = [];
  List<Map<String, dynamic>> get lastTop10Scores => _lastTop10Scores;

  RecommendSongUseCase({
    required this.recommendService,
    required this.usedSongsRepository,
    required this.songCatalogRepository,
    required this.embeddingsService,
  });

  RecommendationResult _noneResult(String diaryEntryId, String reason) {
    return RecommendationResult(
      diaryEntryId: diaryEntryId,
      songId: 'NONE',
      reason: reason,
      matchedLines: const [],
      generatedAt: DateTime.now(),
      model: 'none',
      confidence: 0.0,
    );
  }

  Future<void> markUsedIfNeeded(RecommendationResult result) async {
    if (result.songId == 'NONE') return;
    await usedSongsRepository.markUsed(result.songId);
  }

  Future<RecommendationResult> execute({
    required String diaryEntryId,
    required String diaryText,
  }) async {
    final catalogAll = await songCatalogRepository.getTopSongs();
    final excluded = await usedSongsRepository.getUsedSongIds();
    final available = catalogAll.where((s) => !excluded.contains(s.id)).toList();

    if (available.isEmpty) {
      _lastTop10Scores = [];
      return _noneResult(diaryEntryId, '추천할 수 있는 곡이 없습니다.');
    }

    String songTextForEmbedding(Song s) {
      final snip = (s.lyricsSnippet ?? '').trim();
      if (snip.isEmpty) return '${s.title} - ${s.artist}';
      return '${s.title} - ${s.artist}\n$snip';
    }

    final inputs = <String>[diaryText, ...available.map(songTextForEmbedding)];
    final vectors = await embeddingsService.embedBatch(inputs);

    final diaryVec = vectors[0];

    final scored = <({Song song, double score})>[];
    for (int i = 0; i < available.length; i++) {
      final songVec = vectors[i + 1];
      final sim = cosineSimilarity(diaryVec, songVec);
      scored.add((song: available[i], score: sim));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final topKPairs = scored.take(10).toList();
    final topK = topKPairs.map((e) => e.song).toList();

    _lastTop10Scores = topKPairs
        .map((e) => {
      'id': e.song.id,
      'title': e.song.title,
      'artist': e.song.artist,
      'score': e.score,
    })
        .toList();

    if (topK.isEmpty) {
      return _noneResult(diaryEntryId, '추천할 수 있는 곡이 없습니다.');
    }

    final result = await recommendService.recommend(
      diaryEntryId: diaryEntryId,
      request: RecommendRequest(
        diaryText: diaryText,
        catalog: topK,
        excludedSongIds: excluded,
      ),
    );

    return result;
  }
}
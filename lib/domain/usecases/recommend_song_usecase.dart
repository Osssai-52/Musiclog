import '../models/song.dart';
import '../models/recommendation_result.dart';

import '../repositories/song_catalog_repository.dart';
import '../repositories/used_songs_repository.dart';

import '../services/recommend_service.dart';
import '../models/recommend_request.dart';

class RecommendSongUseCase {
    final RecommendService recommendService;
    final UsedSongsRepository usedSongsRepository;
    final SongCatalogRepository songCatalogRepository;

    RecommendSongUseCase({
        required this.recommendService,
        required this.usedSongsRepository,
        required this.songCatalogRepository,
    });

    Future<RecommendationResult> execute({
        required String diaryEntryId,
        required String diaryText,
    }) async {
        final catalog = await songCatalogRepository.getTopSongs();
        final excluded = await usedSongsRepository.getUsedSongIds();

        final result = await recommendService.recommend(
            diaryEntryId: diaryEntryId,
            request: RecommendRequest(
                diaryText: diaryText,
                catalog: catalog,
                excludedSongIds: excluded,
            ),
        );

        await usedSongsRepository.markUsed(result.songId);
        return result;
    }
}

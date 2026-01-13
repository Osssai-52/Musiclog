import '../data/datasources/apple_music_song_remote_data_source.dart';
import '../data/repositories/song_catalog_repository_impl.dart';
import '../data/repositories/used_songs_repository_prefs.dart';
import '../data/services/openai_embeddings_service.dart';
import '../data/services/openai_recommend_service.dart';

import '../domain/repositories/song_catalog_repository.dart';
import '../domain/repositories/used_songs_repository.dart';
import '../domain/usecases/recommend_song_usecase.dart';

class AppDependencies {
  late final SongCatalogRepository songCatalogRepository;
  late final UsedSongsRepository usedSongsRepository;
  late final RecommendSongUseCase recommendSongUseCase;

  AppDependencies({SongCatalogRepository? songCatalogRepositoryOverride}) {
    final apiKey = const String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY is not set. Use --dart-define.');
    }

    songCatalogRepository = songCatalogRepositoryOverride ??
        SongCatalogRepositoryImpl(AppleMusicSongRemoteDataSource());

    usedSongsRepository = UsedSongsRepositoryPrefs();
    final embeddingsService = OpenAiEmbeddingsService(apiKey: apiKey);
    final recommendService = OpenAiRecommendService(apiKey: apiKey);

    recommendSongUseCase = RecommendSongUseCase(
      songCatalogRepository: songCatalogRepository,
      usedSongsRepository: usedSongsRepository,
      embeddingsService: embeddingsService,
      recommendService: recommendService,
    );
  }
}
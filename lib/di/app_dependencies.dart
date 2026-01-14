import '../data/datasources/apple_music_song_remote_data_source.dart';
import '../data/repositories/song_catalog_repository_impl.dart';
import '../data/repositories/used_songs_repository_prefs.dart';
import '../data/repositories/local_diary_repository.dart';
import '../data/services/openai_embeddings_service.dart';
import '../data/services/openai_recommend_service.dart';

import '../domain/usecases/recommend_song_usecase.dart';
import '../domain/repositories/song_catalog_repository.dart';
import '../domain/repositories/used_songs_repository.dart';
import '../domain/repositories/diary_repository.dart';
import '../domain/services/recommend_service.dart';

class AppDependencies {
  late final SongCatalogRepository songCatalogRepository;
  late final UsedSongsRepository usedSongsRepository;
  late final RecommendSongUseCase recommendSongUseCase;
  late final DiaryRepository diaryRepository;
  late final RecommendService recommendService;

  AppDependencies({
    SongCatalogRepository? songCatalogRepositoryOverride,
    UsedSongsRepository? usedSongsRepositoryOverride,
    DiaryRepository? diaryRepositoryOverride,
    RecommendService? recommendServiceOverride,
    String? openAiApiKeyOverride,
  }) {
    // 1) API KEY
    final openAiApiKey = openAiApiKeyOverride ??
        const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

    if (openAiApiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY is not set. Use --dart-define.');
    }

    // 2) Diary repository (기본: 로컬)
    diaryRepository = diaryRepositoryOverride ?? LocalDiaryRepository();

    // 3) Song catalog repository (기본: Apple Music remote)
    songCatalogRepository = songCatalogRepositoryOverride ??
        SongCatalogRepositoryImpl(AppleMusicSongRemoteDataSource());

    // 4) Used songs repository (기본: SharedPreferences)
    usedSongsRepository = usedSongsRepositoryOverride ?? UsedSongsRepositoryPrefs();

    // 5) Services
    final embeddingsService = OpenAiEmbeddingsService(apiKey: openAiApiKey);
    recommendService = recommendServiceOverride ?? OpenAiRecommendService(apiKey: openAiApiKey);

    // 6) Usecase
    recommendSongUseCase = RecommendSongUseCase(
      songCatalogRepository: songCatalogRepository,
      usedSongsRepository: usedSongsRepository,
      embeddingsService: embeddingsService,
      recommendService: recommendService,
    );
  }
}
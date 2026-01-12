import '../data/datasources/apple_music_song_remote_data_source.dart';
import '../data/datasources/song_remote_data_source.dart';
import '../data/repositories/song_catalog_repository_impl.dart';
import '../data/repositories/in_memory_used_songs_repository.dart';
import '../data/services/openai_recommend_service.dart';

import '../domain/usecases/recommend_song_usecase.dart';
import '../domain/repositories/song_catalog_repository.dart';
import '../domain/repositories/used_songs_repository.dart';
import '../domain/services/recommend_service.dart';

class AppDependencies {
    late final SongCatalogRepository songCatalogRepository;
    late final UsedSongsRepository usedSongsRepository;
    late final RecommendSongUseCase recommendSongUseCase;

    AppDependencies() {
        // ✅ OpenAI API Key (dart-define)
        const openAiApiKey = String.fromEnvironment(
        'OPENAI_API_KEY',
        defaultValue: '',
        );

        if (openAiApiKey.isEmpty) {
        throw Exception('OPENAI_API_KEY is not set. Use --dart-define.');
        }

        // DataSource
        final SongRemoteDataSource songRemoteDataSource =
            AppleMusicSongRemoteDataSource();

        // Repository
        songCatalogRepository =
            SongCatalogRepositoryImpl(songRemoteDataSource);

        usedSongsRepository = InMemoryUsedSongsRepository();

        // ✅ OpenAI Recommend Service
        final RecommendService recommendService =
            OpenAiRecommendService(openAiApiKey);

        // UseCase
        recommendSongUseCase = RecommendSongUseCase(
        recommendService: recommendService,
        songCatalogRepository: songCatalogRepository,
        usedSongsRepository: usedSongsRepository,
        );
    }
}

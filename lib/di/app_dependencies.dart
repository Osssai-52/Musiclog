import '../data/repositories/used_songs_repository_fake.dart';
import '../data/repositories/fake_song_catalog_repository.dart';
import '../data/services/fake_recommend_service.dart';
import '../domain/usecases/recommend_song_usecase.dart';
import '../domain/repositories/song_catalog_repository.dart';
import '../domain/repositories/used_songs_repository.dart';

class AppDependencies {
    late final SongCatalogRepository songCatalogRepository;
    late final UsedSongsRepository usedSongsRepository;
    late final RecommendSongUseCase recommendSongUseCase;

    AppDependencies() {
        songCatalogRepository = FakeSongCatalogRepository();
        usedSongsRepository = FakeUsedSongsRepository();

        recommendSongUseCase = RecommendSongUseCase(
            recommendService: FakeRecommendService(),
            usedSongsRepository: usedSongsRepository,
            songCatalogRepository: songCatalogRepository,
        );
    }
}


import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'di/app_dependencies.dart';
import 'domain/models/song.dart';
import 'domain/models/diary_entry.dart';
import 'domain/models/recommendation_result.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  Hive.registerAdapter(DiaryEntryAdapter());
  Hive.registerAdapter(RecommendationResultAdapter());

  await Hive.openBox<DiaryEntry>('diary');

  final dependencies = AppDependencies();
  runApp(MyApp(dependencies: dependencies));
}

class MyApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MyApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musiclog Backend Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(dependencies: dependencies),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppDependencies dependencies;

  const HomePage({super.key, required this.dependencies});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _resultText = "일기를 쓰고 추천 버튼을 눌러보세요.";
  bool _isLoading = false;

  Future<void> _getRecommendation() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _resultText = "Musiclog가 목록 내에서 적절한 곡을 찾는 중입니다...";
    });

    try {
      final now = DateTime.now();

      final diaryEntry =
          await widget.dependencies.diaryRepository.upsertForDate(
        date: now,
        content: _controller.text,
      );

      final result =
          await widget.dependencies.recommendSongUseCase.execute(
        diaryEntryId: diaryEntry.id,
        diaryText: _controller.text,
      );

      await widget.dependencies.diaryRepository.attachRecommendation(
        diaryEntryId: diaryEntry.id,
        recommendation: result,
      );

      final allSongs =
          await widget.dependencies.songCatalogRepository.getTopSongs();

      Song? recommendedSong;
      try {
        recommendedSong =
            allSongs.firstWhere((s) => s.id == result.songId);
      } catch (_) {
        recommendedSong = null;
      }

      setState(() {
        if (recommendedSong != null) {
          _resultText =
              "🎵 추천 곡: ${recommendedSong.title}\n"
              "👤 아티스트: ${recommendedSong.artist}\n"
              "🆔 곡 ID: ${result.songId}\n\n"
              "📝 추천 이유:\n${result.reason}\n\n"
              "💾 일기 저장 완료";
        } else {
          _resultText =
              "⚠️ 목록에 없는 곡(ID: ${result.songId}) 추천됨\n\n"
              "📝 추천 이유:\n${result.reason}\n\n"
              "💾 일기 저장 완료";
        }
      });
    } catch (e) {
      setState(() {
        _resultText = "에러가 발생했습니다: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musiclog AI Test (Save Enabled)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "오늘의 일기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '여기에 일기를 입력하세요...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _getRecommendation,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('저장 + 노래 추천'),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                child: SelectableText(
                  _resultText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

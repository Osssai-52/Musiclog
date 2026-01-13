import 'package:flutter/material.dart';
import 'di/app_dependencies.dart';
import 'domain/models/song.dart'; 

void main() {
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
      final result = await widget.dependencies.recommendSongUseCase.execute(
        diaryEntryId: 'test-diary-${DateTime.now().millisecondsSinceEpoch}',
        diaryText: _controller.text,
      );

      final allSongs = await widget.dependencies.songCatalogRepository.getTopSongs();

      Song? recommendedSong;
      try {
        recommendedSong = allSongs.firstWhere((s) => s.id == result.songId);
      } catch (e) {
        recommendedSong = null;
      }

      setState(() {
        if (recommendedSong != null) {
          _resultText = "🎵 추천 곡: ${recommendedSong.title}\n"
                        "👤 아티스트: ${recommendedSong.artist}\n"
                        "🆔 곡 ID: ${result.songId}\n\n"
                        "📝 추천 이유:\n${result.reason}";
        } else {
          // AI가 카탈로그에 없는 ID를 줬을 때 (Hallucination 방지)
          _resultText = "⚠️ Musiclog가 목록에 없는 곡(ID: ${result.songId})을 추천했습니다.\n\n"
                        "📝 Musiclog의 추천 이유:\n${result.reason}";
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
        title: const Text('Musiclog AI Test (With Catalog Check)'),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('AI 노래 추천받기'),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              const Text(
                "추천 결과",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
                ),
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
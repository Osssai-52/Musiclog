import 'package:flutter/material.dart';
import 'di/app_dependencies.dart';
import 'domain/models/song.dart'; // Song 모델 import 확인 필요

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
      _resultText = "AI가 카탈로그 내에서 적절한 곡을 찾는 중입니다...";
    });

    try {
      // 1. 추천 로직 실행 (결과로 songId를 받아옴)
      final result = await widget.dependencies.recommendSongUseCase.execute(
        diaryEntryId: 'test-diary-${DateTime.now().millisecondsSinceEpoch}',
        diaryText: _controller.text,
      );

      // 2. 곡 목록(Catalog)에서 추천된 ID와 일치하는 실제 곡 정보 찾기
      final allSongs = await widget.dependencies.songCatalogRepository.getTopSongs();
      
      // AI가 준 ID와 일치하는 곡 검색
      Song? recommendedSong;
      try {
        recommendedSong = allSongs.firstWhere((s) => s.id == result.songId);
      } catch (e) {
        recommendedSong = null;
      }

      setState(() {
        if (recommendedSong != null) {
          // 목록에 있는 곡을 정상적으로 추천했을 때
          _resultText = "🎵 추천 곡: ${recommendedSong.title}\n"
                        "👤 아티스트: ${recommendedSong.artist}\n"
                        "🆔 곡 ID: ${result.songId}\n\n"
                        "📝 추천 이유:\n${result.reason}";
        } else {
          // AI가 카탈로그에 없는 ID를 줬을 때 (Hallucination 방지용 안내)
          _resultText = "⚠️ AI가 목록에 없는 곡(ID: ${result.songId})을 추천했습니다.\n\n"
                        "📝 AI의 추천 이유:\n${result.reason}\n\n"
                        "(해결책: 프롬프트에 '주어진 목록 내에서만 추천하라'는 지시를 강화해야 합니다.)";
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
                  hintText: '여기에 일기를 입력하세요 (영문 문장 테스트 권장)...',
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
                child: SelectableText( // 결과 복사가 가능하도록 SelectableText 사용
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
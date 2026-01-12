import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/services/recommend_service.dart';
import '../../domain/services/recommend_request.dart';
import '../../domain/models/recommendation_result.dart';
import '../../domain/models/song.dart';

class OpenAiRecommendService implements RecommendService {
    final String apiKey;

    OpenAiRecommendService(this.apiKey) {
        if (apiKey.isEmpty) {
        throw Exception('OPENAI_API_KEY is empty. Did you forget --dart-define?');
        }
    }

    @override
    Future<RecommendationResult> recommend({
        required String diaryEntryId,
        required RecommendRequest request,
    }) async {
        final prompt = _buildPrompt(
        diaryText: request.diaryText,
        catalog: request.catalog,
        excludedSongIds: request.excludedSongIds.toList(),
        mood: request.mood,
        );

        final responseJson = await _callGptApi(prompt);

        final songId = responseJson['songId'] as String?;
        if (songId == null || !request.catalog.any((s) => s.id == songId)) {
        throw Exception('GPT returned invalid songId: $songId');
        }

        return RecommendationResult(
        diaryEntryId: diaryEntryId,
        songId: songId,
        reason: responseJson['reason'] as String? ?? '추천 이유를 생성할 수 없습니다.',
        matchedLines: [
            responseJson['matchedEmotion'] as String? ?? '감정 분석 실패'
        ],
        generatedAt: DateTime.now(),
        model: 'gpt-4o-mini',
        );
    }

    // -------------------------
    // 프롬프트 생성
    // -------------------------
    String _buildPrompt({
        required String diaryText,
        required List<Song> catalog,
        required List<String> excludedSongIds,
        String? mood,
    }) {
        final availableSongs = catalog
            .where((s) => !excludedSongIds.contains(s.id))
            .map((s) => '- id: ${s.id}, title: ${s.title}, artist: ${s.artist}')
            .join('\n');

        final moodSection = mood != null && mood.isNotEmpty
            ? '[사용자가 선택한 감정]\n$mood'
            : '';

        return '''
    너는 사용자의 일기를 분석해 감정에 어울리는 노래를 추천하는 AI다.
    반드시 아래 노래 목록 안에서만 선택해야 한다.

    [일기]
    """
    $diaryText
    """
    $moodSection

    [노래 목록]
    $availableSongs

    [응답 규칙]
    - 반드시 하나의 노래만 선택
    - songId는 목록에 있는 값만 사용
    - 이유는 한국어로 1~2문장
    - 아래 JSON 형식으로만 응답

    {
    "songId": "string",
    "reason": "string",
    "matchedEmotion": "string"
    }
    ''';
    }

    // -------------------------
    // OpenAI API 호출
    // -------------------------
    Future<Map<String, dynamic>> _callGptApi(String prompt) async {
        final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': [
            {
                'role': 'system',
                'content': '너는 감정 기반 음악 추천 AI다.',
            },
            {
                'role': 'user',
                'content': prompt,
            },
            ],
            'temperature': 0.7,
        }),
        );

        if (response.statusCode != 200) {
        throw Exception(
            'OpenAI API Error (${response.statusCode}): ${utf8.decode(response.bodyBytes)}',
        );
        }

        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        final content =
            decoded['choices']?[0]?['message']?['content'] as String?;

        if (content == null || content.isEmpty) {
        throw Exception('GPT returned empty response');
        }

        try {
        return jsonDecode(content) as Map<String, dynamic>;
        } catch (_) {
        throw Exception('Failed to parse GPT JSON:\n$content');
        }
    }
}

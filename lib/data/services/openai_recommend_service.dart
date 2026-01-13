import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/services/recommend_service.dart';
import '../../domain/models/recommend_request.dart';
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
        );

        final responseJson = await _callGptApi(prompt);

        final String matchedEmotion =
            (responseJson['emotionKeyword'] as String?) ??
            ((responseJson['emotions'] is List && (responseJson['emotions'] as List).isNotEmpty)
                ? (responseJson['emotions'][0] as String?)
                : null) ??
            '감정 분석 실패';

        final double confidence =
            (responseJson['confidence'] is num)
                ? (responseJson['confidence'] as num).toDouble()
                : 0.5; // fallback

        final songId = responseJson['songId'] as String?;

        if (songId == null) {
            throw Exception('GPT did not return songId');
        }

        if (songId == 'NONE') {
            return RecommendationResult(
                diaryEntryId: diaryEntryId,
                songId: 'NONE',
                reason: responseJson['reason'] as String? ?? '추천할 수 있는 곡이 없습니다.',
                matchedLines: [matchedEmotion],
                generatedAt: DateTime.now(),
                model: 'gpt-4o-mini',
                confidence: confidence,
            );
        }

        if (!request.catalog.any((s) => s.id == songId)) {
            throw Exception('GPT returned invalid songId: $songId');
        }


        return RecommendationResult(
            diaryEntryId: diaryEntryId,
            songId: songId,
            reason: responseJson['reason'] as String? ?? '추천 이유를 생성할 수 없습니다.',
            matchedLines: [matchedEmotion],
            generatedAt: DateTime.now(),
            model: 'gpt-4o-mini',
            confidence: confidence,
        );
    }

    // -------------------------
    // 프롬프트 생성
    // -------------------------
    String _buildPrompt({
        required String diaryText,
        required List<Song> catalog,
        required List<String> excludedSongIds,
    }) {
        final availableSongs = catalog
            .where((s) => !excludedSongIds.contains(s.id))
            .map((s) => '- id: ${s.id}, title: ${s.title}, artist: ${s.artist}, lyricsFull: ${s.lyricsFull}')
            .join('\n');

        return '''
    You are an AI that analyzes a user’s diary, infers the emotions and overall mood expressed in the writing on its own, and recommends a song that best fits those emotions.

    [Diary]
    """
    $diaryText
    """

    [Song List]
    $availableSongs

    [Tasks]
    1. Infer up to two primary emotions that are most strongly expressed in the diary.
    2. Select one keyword that best represents today’s overall emotion.
    3. Choose one song from the list that best matches the inferred emotions and mood.

    [Response Rules]
    - IMPORTANT: You are prohibited from recommending songs outside the provided list. Even if a famous song fits the mood, if it is not in the list, you must not pick it. Check the list twice before answering.
    - Only one song is allowed.
    - If no suitable song can be selected, return "NONE" as the songId.
    - Mention the song title first, then provide the recommendation reason in Korean in 1–2 sentences.
    - Do not provide counseling, solutions, or comforting messages.
    - Minimize expressions of empathy and focus on musical aspects.
    - Respond strictly in the JSON format specified below.
    - Do not output any text outside of the JSON.
    - Returning a songId that does not exist in the list will cause a system error.
    - Focus primarily on the diary’s emotions. Use song information only to match musical mood and tone.
    - confidence must be a number between 0.0 and 1.0.
    - The score represents how confidently the song matches the diary’s emotions and overall mood.

    [Output Format]
    {
    "emotions": ["string", "string"],
    "emotionKeyword": "string",
    "songId": "string",
    "reason": "string",
    "confidence": 0.0
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
                'content': 'You are an emotion-based music recommendation AI.',
            },
            {
                'role': 'user',
                'content': prompt,
            },
            ],
            'temperature': 0.5,
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

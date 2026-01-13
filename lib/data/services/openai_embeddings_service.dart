import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAiEmbeddingsService {
  final String apiKey;
  final String model;

  OpenAiEmbeddingsService({
    required this.apiKey,
    this.model = 'text-embedding-3-small',
  });

  Future<List<List<double>>> embedBatch(List<String> inputs) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/embeddings'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'input': inputs, // 배열 batch 지원  [oai_citation:5‡OpenAI 플랫폼](https://platform.openai.com/docs/api-reference/embeddings?utm_source=chatgpt.com)
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Embeddings API Error (${res.statusCode}): ${utf8.decode(res.bodyBytes)}');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final data = (decoded['data'] as List).cast<Map<String, dynamic>>();

    return data
        .map((e) => (e['embedding'] as List).map((x) => (x as num).toDouble()).toList())
        .toList();
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dtos/song_dto.dart';

abstract class SongRemoteDataSource {
  // static 변수로 선언하여 하위 클래스에서 접근 가능하게 합니다.
  static const String _baseUrl = "https://appel-music-jwt-kax5-hat7qrert-xistoh162108s-projects.vercel.app/api";
  
  Future<List<SongDto>> fetchTopSongs();
}

// 1. 실제 동작을 수행할 클래스(구현체)가 필요합니다.
class SongRemoteDataSourceImpl implements SongRemoteDataSource {
  
  @override
  Future<List<SongDto>> fetchTopSongs() async {
    // 2. abstract 클래스에 선언된 static 변수를 참조합니다.
    final response = await http.get(Uri.parse(SongRemoteDataSource._baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch songs: ${response.statusCode}');
    }

    final dynamic json = jsonDecode(response.body);
    List<dynamic> jsonList;

    if (json is List) {
      jsonList = json;
    } else if (json is Map<String, dynamic>) {
      if (json.containsKey('data')) {
        jsonList = json['data'] as List<dynamic>;
      } else if (json.containsKey('songs')) {
        jsonList = json['songs'] as List<dynamic>;
      } else if (json.containsKey('results')) {
        jsonList = json['results'] as List<dynamic>;
      } else {
        throw Exception('Unknown API response format');
      }
    } else {
      throw Exception('Unexpected response type');
    }

    return jsonList
        .map((item) => SongDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
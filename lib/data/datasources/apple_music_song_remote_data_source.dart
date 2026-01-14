import 'dart:convert';
import 'package:http/http.dart' as http;

import '../dtos/song_dto.dart';
import 'song_remote_data_source.dart';

class AppleMusicSongRemoteDataSource implements SongRemoteDataSource {
  static const String _baseUrl =
      'https://appel-music-jwt-kax5-hat7qrert-xistoh162108s-projects.vercel.app/api';

  @override
  Future<List<SongDto>> fetchTopSongs() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch songs: ${response.statusCode}');
    }

    final dynamic json = jsonDecode(response.body);

    List<dynamic> jsonList;
    if (json is List) {
      jsonList = json;
    } else if (json is Map<String, dynamic>) {
      if (json['data'] is List) {
        jsonList = json['data'] as List<dynamic>;
      } else if (json['songs'] is List) {
        jsonList = json['songs'] as List<dynamic>;
      } else if (json['results'] is List) {
        jsonList = json['results'] as List<dynamic>;
      } else {
        throw Exception('Unknown API response format: ${response.body}');
      }
    } else {
      throw Exception('Unexpected response type: ${response.body}');
    }

    return jsonList
        .map((item) => SongDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
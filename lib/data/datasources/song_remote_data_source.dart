import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dtos/song_dto.dart';

abstract class SongRemoteDataSource {
  Future<List<SongDto>> fetchTopSongs();
}

// lib/data/datasources/song_remote_data_source.dart에서
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

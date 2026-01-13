import 'dart:convert';
import 'package:http/http.dart' as http;

import '../dtos/song_dto.dart';
import 'song_remote_data_source.dart';

class AppleMusicSongRemoteDataSource implements SongRemoteDataSource {
    static const _endpoint =
        'https://appel-music-jwt-kax5-hat7qrert-xistoh162108s-projects.vercel.app/api';

    @override
    Future<List<SongDto>> fetchSongs() async {
        final response = await http.get(
        Uri.parse(_endpoint),
        );

        if (response.statusCode != 200) {
        throw Exception('Failed to fetch songs');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List list = decoded['data'];

        return list
            .map((e) => SongDto.fromJson(e as Map<String, dynamic>))
            .toList();
    }

    // fetchTopSongs 메서드
    @override
    Future<List<SongDto>> fetchTopSongs() async {
        // 만약 인기 차트 API 경로가 따로 있다면 주소 끝에 추가하세요 (예: '$_endpoint/top')
        final response = await http.get(
        Uri.parse(_endpoint), 
        );

        if (response.statusCode != 200) {
        throw Exception('Failed to fetch top songs');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List list = decoded['data'];

        return list
            .map((e) => SongDto.fromJson(e as Map<String, dynamic>))
            .toList();
    }
}
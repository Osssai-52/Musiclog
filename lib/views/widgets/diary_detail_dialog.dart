import 'package:flutter/material.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/domain/models/diary_entry.dart';
import 'package:musiclog/domain/models/song.dart';
import 'package:musiclog/domain/repositories/song_catalog_repository.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

class DiaryDetailDialog extends StatefulWidget {
  final DiaryEntry diaryEntry;
  final SongCatalogRepository songRepository;

  const DiaryDetailDialog({
    super.key,
    required this.diaryEntry,
    required this.songRepository,
  });

  @override
  State<DiaryDetailDialog> createState() => _DiaryDetailDialogState();
}

class _DiaryDetailDialogState extends State<DiaryDetailDialog> {
  late AudioPlayer _audioPlayer;
  String? _currentPlayingUrl;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Song?> _getSong(String songId) async {
    return await widget.songRepository.getById(songId);
  }

  Future<void> _playPreview(String? previewUrl) async {
    if (previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preview not available')),
      );
      return;
    }

    try {
      if (_currentPlayingUrl == previewUrl && _audioPlayer.playing) {
        await _audioPlayer.pause();
      } else if (_currentPlayingUrl == previewUrl && !_audioPlayer.playing) {
        await _audioPlayer.play();
      } else {
        _currentPlayingUrl = previewUrl;
        await _audioPlayer.setUrl(previewUrl);
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play preview')),
      );
    }
  }

  Future<void> _launchAppleMusic(String? appleMusicUrl) async {
    if (appleMusicUrl == null || appleMusicUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple Music link not available')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(appleMusicUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch Apple Music')),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening Apple Music')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(widget.diaryEntry.date),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nanum',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),
              Text(
                'Content',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nanum',
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.diaryEntry.content,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Nanum',
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.diaryEntry.recommendation != null) ...[
                Text(
                  'Recommended Song',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nanum',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<Song?>(
                  future: _getSong(widget.diaryEntry.recommendation!.songId),
                  builder: (context, songSnapshot) {
                    if (songSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!songSnapshot.hasData || songSnapshot.data == null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Unable to load song',
                            style: TextStyle(color: AppColors.error)),
                      );
                    }

                    final song = songSnapshot.data!;
                    final recommendation = widget.diaryEntry.recommendation!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: GestureDetector(
                                  onTap: () =>
                                      _launchAppleMusic(song.appleMusicUrl),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: song.coverUrl != null
                                        ? Image.network(
                                      song.coverUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildPlaceholderSmall(),
                                    )
                                        : _buildPlaceholderSmall(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Nanum',
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Nanum',
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: StreamBuilder<bool>(
                                  stream: _audioPlayer.playingStream,
                                  initialData: false,
                                  builder: (context, snapshot) {
                                    final isPlaying = snapshot.data ?? false;
                                    final isThisSongPlaying =
                                        _currentPlayingUrl == song.previewUrl &&
                                            isPlaying;

                                    return GestureDetector(
                                      onTap: () =>
                                          _playPreview(song.previewUrl),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                        child: Icon(
                                          isThisSongPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Why this song?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nanum',
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            recommendation.reason ?? 'No reason provided',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Nanum',
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (recommendation.matchedLines.isNotEmpty) ...[
                          Text(
                            'Matched Lyrics',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nanum',
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              recommendation.matchedLines.join('\n'),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Nanum',
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No song recommendation for this diary',
                    style: TextStyle(
                      fontFamily: 'Nanum',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Created: ${DateFormat('MMM d, yyyy HH:mm').format(widget.diaryEntry.createdAt)}',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Nanum',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderSmall() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.music_note, color: Colors.white, size: 32),
    );
  }
}

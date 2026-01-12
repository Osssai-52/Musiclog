import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import "package:flutter/material.dart";
import 'package:musiclog/constants/colors.dart';
import 'package:musiclog/views/widgets/art_work_image.dart';
// import 'package:music_kit/music_kit.dart';
import 'package:spotify/spotify.dart';

import '../constants/strings.dart';


class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  Color songColor = Color(0xFF251117);
  String artistName = "Tablo (Epik High)";
  String songName = "Sleeping Beauty";
  String musicTrackId = '3WvM2dIR9iIxMGNMP7WsNw';

  @override
  void initState() {
    final credentials = SpotifyApiCredentials(CustomStrings.clientId, CustomStrings.clientSecret);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: songColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.close, color: Colors.transparent),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Singing Now', style: textTheme.bodyMedium?.copyWith(color: CustomColors.primaryColor),),
                      const SizedBox(height: 6,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage("https://plus.unsplash.com/premium_photo-1682125853703-896a05629709?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
                            radius: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(artistName, style: textTheme.bodyLarge?.copyWith(color: Colors.white))
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.close, color: Colors.white,),
                ]
              ),
              const Expanded(flex: 2, child: Center(child: ArtWorkImage(image: 'https://plus.unsplash.com/premium_photo-1682125853703-896a05629709?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),)),
              Expanded(child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(songName, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
                        Text(artistName, style: textTheme.titleMedium?.copyWith(color: Colors.white60)),
                      ],
                    ),
                    const Icon(
                      Icons.favorite,
                      color: CustomColors.primaryColor
                    )
                  ],
                ),
                const SizedBox(height: 7,),
                ProgressBar(
                  progress: const Duration(minutes: 3),
                  total: const Duration(minutes: 3, seconds: 30),
                  bufferedBarColor: Colors.white38,
                  baseBarColor: Colors.white10,
                  thumbColor: Colors.white,
                  progressBarColor: Colors.white,
                  timeLabelTextStyle: TextStyle(color: Colors.white),
                  onSeek: (duration) {
                    print('User selected a new time: $duration');
                  }
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.lyrics_outlined, color: Colors.white)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.play_circle, color: Colors.white, size: 60)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next, color: Colors.white, size: 36)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.loop, color: CustomColors.primaryColor)),
                  ],
                )
              ],))
            ]
          ),
        ),
      )
    );
  }
}

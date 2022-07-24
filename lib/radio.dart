import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'globals.dart';
import 'package:socket_io_client/socket_io_client.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _controllerWaves;
  final AudioHandler _audioHandler = AudioInit.instance.audioHandler;
  final StreamController responseData = AudioInit.instance.responseDataSource;
  final firstResponse = AudioInit.instance.initState;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    _controller.duration = const Duration(milliseconds: 4000);
    _controller.stop();

    _controllerWaves = AnimationController(vsync: this);
    _controllerWaves.duration = const Duration(milliseconds: 6000);
    _controllerWaves.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerWaves.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        return Center(
          child: Stack(children: [
            Column(
              children: [
                Lottie.asset('assets/ondas.json', controller: _controllerWaves),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        Lottie.asset('assets/pulse.json',
                            width: 300, height: 300, controller: _controller),
                        ClipOval(
                          child: Image.asset(
                            'img/avatar.png',
                            width: 200,
                            height: 200,
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: const Color.fromRGBO(170, 0, 0, 1)
                                  .withOpacity(0.3),
                              offset: const Offset(-1, 8),
                              blurRadius: 8,
                              spreadRadius: 1)
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment(0.0,
                                  0.0), // 10% of the width, so there are ten blinds.
                              colors: <Color>[
                                Color.fromRGBO(139, 0, 0, 1),
                                Color.fromRGBO(153, 0, 0, 1),
                              ], // red to yellow, // repeats the gradient over the canvas
                            ),
                          ),
                          child: StreamBuilder<bool>(
                            stream: _audioHandler.playbackState
                                .map((state) => state.playing)
                                .distinct(),
                            builder: (context, snapshot) {
                              final playing = snapshot.data ?? false;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (playing)
                                    IconButton(
                                      icon: const Icon(Icons.stop_rounded),
                                      iconSize: 64.0,
                                      color: Colors.white,
                                      onPressed: () {
                                        _audioHandler.stop();
                                        _controller.stop();
                                      },
                                    )
                                  else
                                    IconButton(
                                      icon:
                                          const Icon(Icons.play_arrow_rounded),
                                      iconSize: 64.0,
                                      color: Colors.white,
                                      onPressed: () {
                                        _audioHandler.play();
                                        _controller.repeat();
                                      },
                                    )
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder(
                        stream: responseData.stream,
                        initialData: firstResponse,
                        builder: (context, AsyncSnapshot snapshot) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(139, 0, 0, 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                )),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 20),
                                    child: ClipOval(
                                      child: Image(
                                        height: 50,
                                        width: 50,
                                        alignment: Alignment.center,
                                        image: NetworkImage(
                                            snapshot.data!['now_playing']
                                                ['song']['art']),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // ignore: prefer_const_literals_to_create_immutables
                                    children: [
                                      Text(
                                        snapshot.data!['now_playing']['song']
                                            ['title'],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        snapshot.data!['now_playing']['song']
                                            ['artist'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    ],
                                  )
                                ]),
                          );
                        }),
                  ],
                )
              ],
            ),
          ]),
        );
      }),
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

/// An [AudioHandler] for playing a single item.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  static final _item = MediaItem(
    id: 'http://150.230.93.192/radio/8000/radio.mp3',
    album: "Rádio IADEP",
    title: "Rádio IADEP",
    artist: "Assembléia de Deus Atos do Evangelho Primitivo",
    artUri: Uri.parse(
        'http://150.230.93.192/static/uploads/album_art.1647722448.jpg'),
  );

  final _player = AudioPlayer();

  /// Initialise our audio handler.
  AudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    mediaItem.add(_item);

    // Load the player.
    _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        if (_player.playing) MediaControl.stop else MediaControl.play,
      ],
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

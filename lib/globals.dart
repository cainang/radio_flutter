import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:radio_flutter/radio.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AudioInit extends ChangeNotifier {
  static AudioInit instance = AudioInit();

  late AudioHandler audioHandler;
  late AnimationController controllerTocando;

  Socket socket = io('http://150.230.93.192:3333', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false
  });

  StreamController<Map> responseDataSource = StreamController<Map>.broadcast();
  late Map initState;
  late ScrollController controllerInstance;

  iniciar() async {
    audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );

    var response =
        await http.get(Uri.parse('http://150.230.93.192/api/nowplaying/1'));
    responseDataSource.add(jsonDecode(utf8.decode(response.bodyBytes)));
    initState = jsonDecode(utf8.decode(response.bodyBytes));

    socket.connect();
    socket.on('music change', (data) {
      print(data);
      var json = jsonDecode(data);
      responseDataSource.add(json);
      initState = json;
    });

    notifyListeners();
  }

  Future<Map> apiGet(url) async {
    var response = await http.get(Uri.parse(url));
    Map json = jsonDecode(response.body);
    return json;
  }

  Future<List> apiGetRequest(url) async {
    var response = await http.get(Uri.parse(url));
    List json = jsonDecode(utf8.decode(response.bodyBytes));
    return json;
  }

  void setControllerInstance(ScrollController controller) {
    controllerInstance = controller;
  }
}

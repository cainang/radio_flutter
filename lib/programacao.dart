import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:radio_flutter/globals.dart';

class ProgramacaoPage extends StatefulWidget {
  const ProgramacaoPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ProgramacaoPage> createState() => _ProgramacaoPageState();
}

class _ProgramacaoPageState extends State<ProgramacaoPage>
    with TickerProviderStateMixin {
  late AnimationController _controllerTocando =
      AudioInit.instance.controllerTocando;
  final AudioHandler _audioHandler = AudioInit.instance.audioHandler;
  final StreamController responseData = AudioInit.instance.responseDataSource;
  final firstResponse = AudioInit.instance.initState;

  @override
  void initState() {
    super.initState();

    _controllerTocando = AnimationController(vsync: this);
    _controllerTocando.duration = const Duration(milliseconds: 2000);
    _controllerTocando.repeat();
    /* Lottie.asset('assets/tocando.json',
                          controller: _controllerTocando,
                          width: 50,
                          height: 100) */
  }

  @override
  void dispose() {
    _controllerTocando.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                      color:
                          const Color.fromRGBO(170, 0, 0, 1).withOpacity(0.3),
                      offset: const Offset(-1, 8),
                      blurRadius: 8,
                      spreadRadius: 1)
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                  color: Color.fromRGBO(170, 0, 0, 1),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                              color: Color.fromRGBO(170, 0, 0, 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Tocando agora',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10, bottom: 10, right: 15),
                                child: IconButton(
                                    icon: const Icon(Icons.queue_music_rounded),
                                    iconSize: 30.0,
                                    color: Colors.white,
                                    onPressed: () => showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20))),
                                        context: context,
                                        builder: (context) => pedidosModal())),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
                initialData: firstResponse,
                stream: responseData.stream,
                builder: (context, AsyncSnapshot snapshot) {
                  return cardMusic(
                      data: snapshot.data!['now_playing'],
                      isPlayingNow: Container(
                        padding: const EdgeInsets.only(top: 15, left: 10),
                        child: StreamBuilder<bool>(
                            stream: _audioHandler.playbackState
                                .map((state) => state.playing)
                                .distinct(),
                            builder: (context, snapshot) {
                              final playing = snapshot.data ?? false;
                              if (playing) {
                                _controllerTocando.repeat();
                              } else {
                                _controllerTocando.stop();
                              }
                              return Lottie.asset('assets/tocando.json',
                                  controller: _controllerTocando,
                                  width: 50,
                                  height: 100);
                            }),
                      ));
                }),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30), top: Radius.circular(30)),
                color: Colors.white,
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                      color:
                          const Color.fromRGBO(170, 0, 0, 1).withOpacity(0.3),
                      offset: const Offset(-1, 8),
                      blurRadius: 8,
                      spreadRadius: 1)
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                    child: const Text('Proxima á Tocar',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(170, 0, 0, 1))),
                  ),
                  SizedBox(
                    width: 500,
                    child: StreamBuilder(
                        initialData: firstResponse,
                        stream: responseData.stream,
                        builder: (context, AsyncSnapshot snapshot) {
                          return cardMusic(
                            data: snapshot.data!['playing_next'],
                          );
                        }),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 25),
                    child: const Text('Musicas Já Tocadas',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(170, 0, 0, 1))),
                  ),
                  SizedBox(
                      height: 310,
                      width: 500,
                      child: StreamBuilder(
                          initialData: firstResponse,
                          stream: responseData.stream,
                          builder: (context, AsyncSnapshot snapshot) {
                            return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: cardMusic(
                                          data: snapshot.data!['song_history']
                                              [index]));
                                });
                          })),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}

Widget cardMusic({data, isPlayingNow}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    height: 80,
    decoration: const BoxDecoration(
        color: Color.fromRGBO(170, 0, 0, 1),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        )),
    child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: isPlayingNow != null
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 15),
            child: ClipOval(
              child: Image(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                image: NetworkImage(data!['song']['art']),
              ),
            ),
          ),
          Container(
            margin: isPlayingNow != null
                ? const EdgeInsets.only(left: 0)
                : const EdgeInsets.only(left: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data!['song']['title'],
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  data!['song']['artist'],
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          if (isPlayingNow != null) isPlayingNow
        ]),
  );
}

Widget pedidosModal() {
  final dadosPedido = AudioInit.instance
      .apiGetRequest('http://150.230.93.192/api/station/1/requests');

  return FutureBuilder<List>(
      future: dadosPedido,
      builder: (context, AsyncSnapshot snapshot) {
        Widget body;
        if (snapshot.hasData) {
          body = Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Peça uma Música',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                    width: 250,
                    child: TextField(),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(170, 0, 0, 1))),
                      onPressed: () {},
                      child: const Icon(Icons.search))
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  controller: AudioInit.instance.controllerInstance,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: cardMusic(
                            data: snapshot.data[index],
                            isPlayingNow: Container(
                                padding:
                                    const EdgeInsets.only(top: 15, left: 10),
                                child: IconButton(
                                  onPressed: () {
                                    /* Fluttertoast.showToast(
                                        msg: "This is Center Short Toast",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0); */
                                  },
                                  icon: const Icon(
                                    Icons.playlist_add_check_rounded,
                                    color: Colors.white,
                                  ),
                                ))));
                  }),
            ),
          ]);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          body = Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          body = const SizedBox(
            width: 60,
            height: 60,
            child: Center(
                child: CircularProgressIndicator(
              color: Color.fromRGBO(170, 0, 0, 1),
            )),
          );
        }

        return DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (_, controller) {
              AudioInit.instance.setControllerInstance(controller);
              return Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                padding: const EdgeInsets.all(16),
                child: body,
              );
            });
      });
}

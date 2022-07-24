import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:radio_flutter/info.dart';
import 'package:radio_flutter/programacao.dart';
import 'package:radio_flutter/radio.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final navigationBar = GlobalKey<CurvedNavigationBarState>();
  int _page = 1;

  final screens = [
    const ProgramacaoPage(title: 'title'),
    const RadioPage(title: 'title'),
    const InfoPage(title: 'title')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: CurvedNavigationBar(
            key: navigationBar,
            index: _page,
            backgroundColor: Colors.transparent,
            buttonBackgroundColor: const Color.fromRGBO(170, 0, 0, 1),
            color: const Color.fromRGBO(139, 0, 0, 1),
            animationDuration: const Duration(milliseconds: 300),
            items: const <Widget>[
              Icon(Icons.article, size: 30),
              Icon(Icons.audiotrack_sharp, size: 30),
              Icon(Icons.info, size: 30),
            ],
            onTap: (index) {
              setState(() {
                _page = index;
              });
            },
          )),
      body: screens[_page],
    );
  }
}

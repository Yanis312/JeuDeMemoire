import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'data.dart';

class FlipCardGame extends StatefulWidget {
  final Level _level;
  const FlipCardGame(this._level, {super.key});

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _FlipCardGameState createState() => _FlipCardGameState(_level);
}

class _FlipCardGameState extends State<FlipCardGame> {
  _FlipCardGameState(this._level);

  int _previousIndex = -1;
  bool _flip = false;
  bool _start = false;
  bool _wait = false;
  final Level _level;
  late Timer _timer;
  int _time = 5;
  int _left = 0;
  bool _isFinished = false;
  List<String> _data = [];
  List<bool> _cardFlips = [];
  List<GlobalKey<FlipCardState>> _cardStateKeys = [];
  final AudioCache _audioCache = AudioCache(prefix: 'assets/sounds/');

  Widget getItem(int index) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100],
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 3,
              spreadRadius: 0.8,
              offset: Offset(2.0, 1),
            )
          ],
          borderRadius: BorderRadius.circular(5)),
      margin: const EdgeInsets.all(4.0),
      child: Image.asset(_data[index]),
    );
  }

  void playSound(String imagePath) {
    String soundFileName = '${imagePath.split('/').last.split('.').first}.mp3';
    _audioCache.play(soundFileName);
  }

  int getStartTime(Level level) {
    switch (level) {
      case Level.easy:
        return 2;
      case Level.medium:
        return 4;
      case Level.hard:
        return 6;
      default:
        return 5;
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _time = _time - 1;
      });
    });
  }

  void restart() {
    _time = getStartTime(_level);
    startTimer();
    _data = getSourceArray(_level);
    _cardFlips = getInitialItemState(_level);
    _cardStateKeys = getCardStateKeys(_level);
    _left = (_data.length ~/ 2);
    _isFinished = false;
    Future.delayed(Duration(seconds: _time + 1), () {
      setState(() {
        _start = true;
        _timer.cancel();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    restart();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isFinished
        ? Scaffold(
            body: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    restart();
                  });
                },
                child: Container(
                  height: 50,
                  width: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "Replay",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _time > 0
                          ? Text(
                              '$_time',
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                          : Text(
                              'Left:$_left',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _level == Level.hard
                              ? 8
                              : (_level == Level.medium ? 6 : 4),
                        ),
                        itemBuilder: (context, index) => _start
                            ? FlipCard(
                                key: _cardStateKeys[index],
                                onFlip: () {
                                  if (!_flip) {
                                    _flip = true;
                                    _previousIndex = index;
                                  } else {
                                    _flip = false;
                                    if (_previousIndex != index) {
                                      if (_data[_previousIndex] != _data[index]) {
                                        _wait = true;
                                        Future.delayed(
                                            const Duration(milliseconds: 1500),
                                            () {
                                          _cardStateKeys[_previousIndex]
                                              .currentState
                                              ?.toggleCard();
                                          _previousIndex = index;
                                          _cardStateKeys[_previousIndex]
                                              .currentState
                                              ?.toggleCard();

                                          Future.delayed(
                                              const Duration(milliseconds: 160),
                                              () {
                                            setState(() {
                                              _wait = false;
                                            });
                                          });
                                        });
                                      } else {
                                        _cardFlips[_previousIndex] = false;
                                        _cardFlips[index] = false;
                                        playSound(_data[index]);
                                        if (kDebugMode) {
                                          print(_cardFlips);
                                        }
                                        setState(() {
                                          _left -= 1;
                                        });
                                        if (_cardFlips.every((t) => t == false)) {
                                          if (kDebugMode) {
                                            print("Won");
                                          }
                                          Future.delayed(
                                              const Duration(milliseconds: 160),
                                              () {
                                            setState(() {
                                              _isFinished = true;
                                              _start = false;
                                            });
                                          });
                                        }
                                      }
                                    }
                                    setState(() {});
                                  }
                                },
                                flipOnTouch: _wait ? false : _cardFlips[index],
                                direction: FlipDirection.HORIZONTAL,
                                front: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black45,
                                          blurRadius: 3,
                                          spreadRadius: 0.8,
                                          offset: Offset(2.0, 1),
                                        )
                                      ]),
                                  margin: const EdgeInsets.all(4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      "assets/animalspics/quest.png",
                                    ),
                                  ),
                                ),
                                back: getItem(index))
                            : getItem(index),
                        itemCount: _data.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
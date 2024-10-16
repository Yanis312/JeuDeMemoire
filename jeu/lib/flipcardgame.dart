import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'data.dart'; // Assume this is where you have definitions for Level and Asset

class FlipCardGame extends StatefulWidget {
  final Level level;
  const FlipCardGame(this.level, {super.key});

  @override
  FlipCardGameState createState() => FlipCardGameState();
}

class FlipCardGameState extends State<FlipCardGame> {
  int _previousIndex = -1;
  bool _flip = false;
  bool _wait = false;
  int _left = 0;
  bool _isFinished = false;
  List<Asset> _assets = [];
  List<bool> _cardFlips = [];
  List<GlobalKey<FlipCardState>> _cardStateKeys = [];
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _moveCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _loadInitialState() async {
    _assets = await getSourceArray(widget.level);
    _cardFlips = List.generate(_assets.length, (_) => false);
    _cardStateKeys =
        List.generate(_assets.length, (_) => GlobalKey<FlipCardState>());
    _left = _assets.length ~/ 2;
    _moveCount = 0;
    setState(() {});
  }
/*
  void playSound(String soundUrl) {
    if (soundUrl.isNotEmpty) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(UrlSource(soundUrl));
    }
  }
  */
void playSound(String soundUrl) async {
  if (soundUrl.isNotEmpty) {
    AudioPlayer audioPlayer = AudioPlayer();
    try {
      await audioPlayer.setSource(UrlSource(soundUrl));
      await audioPlayer.resume();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            Text(
              'Cartes retournées: $_moveCount - Temps: ${elapsedTime()}',
              style: TextStyle(
                fontSize: 16.0, // Adjust the font size here
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.0), // Add space between the two lines
            Text(
              'Tourner une seule carte à la fois!',
              style: TextStyle(
                fontSize: 12.0, // Set desired font size for the second line
                color: Colors.redAccent, // Adjust color as needed
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isFinished ? _buildFinishedScreen() : _buildGameScreen(),
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cartes retournées: $_moveCount - Temps: ${elapsedTime()}'),
      ),
      body: SafeArea(
        child: _isFinished ? _buildFinishedScreen() : _buildGameScreen(),
      ),
    );
  }
  */

  String elapsedTime() {
    return _stopwatch.elapsed.inMinutes.toString().padLeft(2, '0') +
        ':' +
        _stopwatch.elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  }

  Widget _buildFinishedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Félicitations ! Vous avez terminé le jeu !',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadInitialState();
                  _isFinished = false;
                  _stopwatch.reset();
                  _stopwatch.start();
                });
              },
              child: const Text('Play Again'))
        ],
      ),
    );
  }

/*
  void _onFlip(int index) {
    if (_wait || _cardFlips[index])
      return; // Ignore if wait state or card already flipped

    if (!_flip) {
      _flip = true;
      _previousIndex = index;
    } else {
      if (_previousIndex == index) {
        // Clicked same card, ignore
        _flip = false;
      } else {
        _moveCount++;
        _wait = true;
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_assets[_previousIndex].imageUrl == _assets[index].imageUrl) {
            _cardFlips[_previousIndex] = true;
            _cardFlips[index] = true;
            playSound(_assets[index].soundUrl);
            _left -= 1;
            if (_left == 0) {
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  _isFinished = true; // Set finished state after 3 seconds
                  _stopwatch.stop();
                });
              });
            }
          } else {
            _cardStateKeys[_previousIndex].currentState?.toggleCard();
            _cardStateKeys[index].currentState?.toggleCard();
          }
          _flip = false;
          _wait = false;
          setState(() {});
        });
      }
    }
  }
*/
void _onFlip(int index) {
  if (_wait || _cardFlips[index])
    return; // Ignore if wait state or card already flipped

  // Show the card in a big format (popup) for 1 second for both the first and second flip
  _showCardPopUp(index);

  if (!_flip) {
    _flip = true;
    _previousIndex = index;
  } else {
    if (_previousIndex == index) {
      // Clicked same card, ignore
      _flip = false;
    } else {
      _moveCount++;
      _wait = true;

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (_assets[_previousIndex].imageUrl == _assets[index].imageUrl) {
          _cardFlips[_previousIndex] = true;
          _cardFlips[index] = true;
          playSound(_assets[index].soundUrl);
          _left -= 1;
          if (_left == 0) {
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                _isFinished = true; // Set finished state after 3 seconds
                _stopwatch.stop();
              });
            });
          }
        } else {
          _cardStateKeys[_previousIndex].currentState?.toggleCard();
          _cardStateKeys[index].currentState?.toggleCard();
        }
        _flip = false;
        _wait = false;
        setState(() {});
      });
    }
  }
}

// Show the card in a big format for 1 second
void _showCardPopUp(int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(_assets[index].imageUrl, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(
                _assets[index].imageName,
                style: TextStyle(
                  fontSize: 20.0, // Larger font size for the pop-up
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  // Automatically dismiss the dialog after 1 second
  Future.delayed(const Duration(seconds: 1), () {
    Navigator.of(context).pop();
  });
}



//flip card end code


  Widget _buildGameScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Paires restantes: $_left',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 16.0, // Set the desired font size here
                  ),
            ),
          ),
          /*
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Paires restantes: $_left',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          */
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.level == Level.hard
                  ? 8
                  : widget.level == Level.medium
                      ? 6
                      : 4,
            ),
            itemCount: _assets.length,
            itemBuilder: (context, index) => FlipCard(
              key: _cardStateKeys[index],
              flipOnTouch: !_cardFlips[index] && !_wait,
              onFlip: () => _onFlip(index),
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
                          offset: Offset(2.0, 1))
                    ]),
                margin: const EdgeInsets.all(4.0),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset("assets/animalspics/quest.png",
                      fit: BoxFit.cover), // Placeholder image
                ),
              ),
              back: getItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget getItem(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
              color: Colors.black45,
              blurRadius: 3,
              spreadRadius: 0.8,
              offset: Offset(2, 1))
        ],
      ),
      margin: const EdgeInsets.all(4.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.network(_assets[index].imageUrl, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
            return Text("Erreur", // de chargement de l'image
                style: TextStyle(color: Colors.red, fontSize: 14.0));
          }),
          Container(
            padding: const EdgeInsets.all(0),
            color: Colors.black54,
            child: Text(
              _assets[index].imageName,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0 // Set your custom font size here)
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

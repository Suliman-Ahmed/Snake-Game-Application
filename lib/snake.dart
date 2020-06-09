import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Snake extends StatefulWidget {
  @override
  _SnakeState createState() => _SnakeState();
}

class _SnakeState extends State<Snake> {
  SharedPreferences sharedPreferences;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (!(sharedPreferences.getInt('HighScore') == null)) {
      highScore = sharedPreferences.getInt('HighScore');
    } else {
      highScore = 0;
    }
  }

  static List<int> snakePosition = [92, 93, 94, 95, 96];
  int numOfSeqers = 360;

  bool isPlaying = false;

  static var randomNum = Random();
  int food = randomNum.nextInt(200);
  var duration;
  List<int> blocks = List<int>(5);

  int score = 0;
  int durationTime = 300;
  int col = 0;

  void generateNewFood() {
    food = randomNum.nextInt(numOfSeqers);
  }

  void startGame() {
    score = 0;
    isPlaying = true;
    direction = 'right';
    generateNewFood();
    snakePosition = [92, 93, 94, 95, 96];
    duration = Duration(milliseconds: 300);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (_gameOver()) {
        timer.cancel();
        _showGameOverScreen();
      }
    });
  }

  var direction = 'down';

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > numOfSeqers - 11) {
            snakePosition.add(snakePosition.last - numOfSeqers);
          } else {
            snakePosition.add(snakePosition.last + 15);
          }
          break;
        case 'up':
          if (snakePosition.last < 16) {
            snakePosition.add(snakePosition.last + numOfSeqers);
          } else {
            snakePosition.add(snakePosition.last - 15);
          }
          break;
        case 'left':
          if (snakePosition.last % 15 == 0) {
            snakePosition.add(snakePosition.last - 1 + 15);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % 15 == 0) {
            snakePosition.add(snakePosition.last + 1 - 15);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }

          break;

        default:
      }

      if (snakePosition[snakePosition.length - 1] == food) {
        generateNewFood();
        score = snakePosition.length - 5;
        eatSound();
        if (score % 2 == 0) {
          durationTime -= 10;
          if (durationTime > 0) {
            duration = Duration(milliseconds: durationTime);
            setState(() {});
          }
        }
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  var colIndex = 0;

  Future<AudioPlayer> eatSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("img/EatSound.ogg");
  }

  Future<AudioPlayer> moveSound(String url) async {
    AudioCache cache = new AudioCache();
    return await cache.play("img/$url.mp3");
  }

  bool _gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count++;
        }
        if (count == 2) {
          return true;
        }
      }
    }
    return false;
  }

  void _showGameOverScreen() {
    moveSound('crash_sound');
    isPlaying = false;
    if (score > highScore) {
      highScore = score;
      sharedPreferences.setInt('HighScore', score);
    } else {
      sharedPreferences.setInt('HighScore', highScore);
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('You\'re score: ' + (score).toString()),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    startGame();
                    Navigator.pop(context);
                  },
                  child: Text('Play Again'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    sharedPreferences.setInt('HighScore', 1);
    return Scaffold(
      backgroundColor: Color(0xffa8d04b),
      appBar: AppBar(
        backgroundColor: Color(0xffa8d04b),
        elevation: .5,
        leading: Center(child: Text('High Score $highScore')),
        centerTitle: true,
        actions: <Widget>[
          Center(
            child: InkWell(
              onTap: () {
                startGame();
              },
              child: Text(
                'START',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ],
        title: Text('Score $score'),
      ),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (direction != 'up' && details.delta.dy > 0) {
                direction = 'down';
                // moveSound('move_sound');
              } else if (direction != 'down' && details.delta.dy < 0) {
                direction = 'up';
                // moveSound('move_sound');
              }
            },
            onHorizontalDragUpdate: (details) {
              if (direction != 'left' && details.delta.dx > 0) {
                direction = 'right';
                // moveSound('move_sound');
              } else if (direction != 'right' && details.delta.dx < 0) {
                direction = 'left';
                // moveSound('move_sound');
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: numOfSeqers,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 15),
                  itemBuilder: (BuildContext context, int index) {
//                    index = colIndex;

//                    print(colIndex);
                    if (snakePosition.contains(index)) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Color(0xff5076f9),
                            ),
                          ),
                        ),
                      );
                    }
                    if (index == food) {
                      return Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/img/apple.png'),
                                    fit: BoxFit.fitHeight)),
                          ),
                        ),
                      );
                    } else {
//                      if (index % 10 == 0) {
//                        colIndex += 1;
//                      }
//                      if (col > 17) col = 0;
                      return Container(
                        child: Container(
                            color:
//                            (colIndex % 2 == 0)
//                                ? (index % 2 == 0)
//                                ? Color(0xff8ecc39)
//                                : Color(0xffa8d04b)
//                                : !
                                (index % 2 == 0)
                                    ? Color(0xff8ecc39)
                                    : Color(0xffa8d04b)),
                      );
                    }
                  }),
            ),
          ),

          /*
           Padding(
            padding: const EdgeInsets.all(8.0),
            child:isPlaying ? SizedBox() : Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      startGame();
                    },
                    child: Text(
                      'S T A R T',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  Text(
                    'Score = $score',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text(
                    'High Score = $highScore',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakegame/snake_colors.dart';

class Snake extends StatefulWidget {
  final SnakeColors snakeColor;

  Snake(this.snakeColor);

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
  int numOfSeqers = 315;

  bool isPlaying = false;
  bool isStop = false;

  static var randomNum = Random();
  int food = randomNum.nextInt(200);
  var duration;
  List<int> bombs = [20, 30, 50, 80, 90];

  int score = 0;
  int durationTime = 300;
  int col = 0;

  var timers;

  void generateNewFood() {
    food = randomNum.nextInt(numOfSeqers - 45);
    if (snakePosition.contains(food) || bombs.contains(food)) {
      generateNewFood();
    }
  }

  void checkBombs() {
    for (int i = 0; i < bombs.length; i++) {
      if (food == bombs[i]) {
        bombs[i] = randomNum.nextInt(numOfSeqers);
      }
    }
  }

  void generateBombs() {
    for (int i = 0; i < bombs.length; i++) {
      bombs[i] = randomNum.nextInt(numOfSeqers);
    }
  }

  int bombIndex = 0;
  void generateLastBomb(){
    bombs[bombIndex] = randomNum.nextInt(numOfSeqers);
  }

  void startGame() {
    score = 0;
    isPlaying = true;
    direction = 'right';
    durationTime = 300;
    generateNewFood();
    generateBombs();
    snakePosition = [92, 93, 94, 95, 96];
    duration = Duration(milliseconds: durationTime);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (_gameOver(false)) {
        timer.cancel();
        _showGameOverScreen();
      }
    });
  }

  void stopGame() {
    setState(() {
      isPlaying = false;
      durationTime = 9000;
    });
    snakePosition = [92, 93, 94, 95, 96];
    duration = Duration(milliseconds: durationTime);
  }

  var direction = 'down';

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > numOfSeqers) {
            snakePosition.add(snakePosition.last - numOfSeqers);
          } else {
            snakePosition.add(snakePosition.last + 15);
          }
          break;
        case 'up':
          if (snakePosition.last < 5) {
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
        bombIndex++;
        (bombIndex > 5) ? bombIndex = 0 : bombIndex = bombIndex;
        (score!= 0 && score % 5 == 0) ? generateLastBomb() : print('no bomb');
        if (score % 2 == 0) {
          durationTime -= 10;
          if (durationTime > 0) {
            duration = Duration(milliseconds: durationTime);
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

  bool _gameOver(bool isPlay) {
    if (isPlay == true) {
      return true;
    }
    for (int j = 0; j < bombs.length; j++) {
      if (snakePosition.last == bombs[j]) {
        return true;
      }
    }

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
    bombIndex = 0;
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

    int size1 = (_height ~/ 2).toInt();
    for (int i = 0; i < 10; i++) {
      if (size1 % 15 != 0) {
        size1 -= ((_height / 2) % 15).toInt();
      } else {
        break;
      }
    }
    numOfSeqers = size1;
    return Scaffold(
      backgroundColor: widget.snakeColor.seqColor1,
      appBar: AppBar(
        backgroundColor: widget.snakeColor.color,
        elevation: .5,
        leading: Center(
            child: Text(
          'High Score $highScore',
          style: TextStyle(
            color: (widget.snakeColor.color == Colors.white)
                ? Colors.black
                : Colors.white,
          ),
        )),
        centerTitle: true,
        title: Text(
          'Score $score',
          style: TextStyle(
            color: (widget.snakeColor.color == Colors.white)
                ? Colors.black
                : Colors.white,
          ),
        ),
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
                    crossAxisCount: 15,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (snakePosition.contains(index)) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: widget.snakeColor.color,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.black, width: .5)),
                            ),
                          ),
                        ),
                      );
                    }
                    if (bombs.contains(index)) {
                      return Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(widget.snakeColor.bomb),
                                    fit: BoxFit.fitHeight)),
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
                                    image: AssetImage(widget.snakeColor.food),
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
                                  ? widget.snakeColor.seqColor1
                                  : widget.snakeColor.seqColor2
                        ),
                      );
                    }
                  }),
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isStop = !isStop;
          });
          isStop ? startGame() : stopGame();
        },
        child: Icon(isStop ? Icons.pause : Icons.play_arrow,color: widget.snakeColor.textColor,),
        backgroundColor: widget.snakeColor.color,
      ),
    );
  }
}

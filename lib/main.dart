import 'package:flutter/material.dart';
import 'package:snakegame/snake.dart';
import 'package:snakegame/snake_colors.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const TextStyle style1 = TextStyle(
        fontFamily: 'ARCADECLASSIC', fontSize: 25, color: Colors.white);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: TextTheme(
        display1: style1,
        button: style1,
        body1: style1,
      )),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SnakeColors> snakes = <SnakeColors>[
    SnakeColors(
      name: 'Blue',
      food: 'assets/img/apple.png',
      bomb: 'assets/img/bomb.png',
      color: Color(0xff5076f9),
      textColor: Colors.white,
      seqColor1: Color(0xff8ecc39),
      seqColor2: Color(0xffa8d04b),
      backgroundImage: 'assets/img/backgroundImage1.png'
    ),
    SnakeColors(
      name: 'Pink',
      food: 'assets/img/watermelon.png',
      bomb: 'assets/img/rock.png',
      color: Colors.pinkAccent,
      textColor: Colors.white,
      seqColor1: Color(0xff363636),
      seqColor2: Color(0xff313131),
        backgroundImage: 'assets/img/backgroundImage2.png'
    ),
    SnakeColors(
      name: 'Black',
      food: 'assets/img/cherry.png',
      bomb: 'assets/img/bomb.png',
      color: Color(0xff363636),
      textColor: Colors.white,
      seqColor1: Color(0xff87A8A7),
      seqColor2: Color(0xffA2C7BA),
        backgroundImage: 'assets/img/backgroundImage3.png'
    ),
    SnakeColors(
      name: 'White',
      food: 'assets/img/pineapple.png',
      bomb: 'assets/img/rock.png',
      color: Colors.white70,
      textColor: Colors.grey[700],
      seqColor1: Color(0xff363636),
      seqColor2: Color(0xff313131),
        backgroundImage: 'assets/img/backgroundImage4.png'
    ),
    SnakeColors(
      name: 'Red',
      food: 'assets/img/kiwi.png',
      bomb: 'assets/img/rock.png',
      color: Colors.red[700],
      textColor: Colors.white,
      seqColor1: Color(0xff33517E),
      seqColor2: Color(0xff2F4858),
        backgroundImage: 'assets/img/backgroundImage5.png'
    ),
    SnakeColors(
        name: 'Pink 2',
        food: 'assets/img/cherry.png',
        bomb: 'assets/img/bomb.png',
        color: Color(0xffd26481),
        textColor: Colors.white,
        seqColor1: Color(0xff8ecc39),
        seqColor2: Color(0xffa8d04b),
        backgroundImage: 'assets/img/backgroundImage6.png'
    ),
  ];

  SnakeColors selectedColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  selectedColor == null
                      ? 'assets/img/backgroundImage.png'
                      : selectedColor.backgroundImage,
                ),
                fit: BoxFit.cover)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  print('Play');
                  (selectedColor == null)
                      ? Toast.show("Please select a color", context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Snake(selectedColor)));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff5076f9),
                      borderRadius: BorderRadius.circular(40)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Text(
                    'Play',
                    style: TextStyle(
                        fontFamily: 'ARCADECLASSIC',
                        fontSize: 25,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 40),
              DropdownButtonHideUnderline(
                child: DropdownButton<SnakeColors>(
                  value: selectedColor,
                  onChanged: (SnakeColors Value) {
                    setState(() {
                      selectedColor = Value;
                      print(selectedColor.name);
                    });
                  },
                  hint: Text('Please   Select   a   color'),
                  style: TextStyle(
                    fontFamily: 'ARCADECLASSIC',
                    wordSpacing: .5,
                    fontSize: 18,
                  ),
                  items: snakes.map((SnakeColors snakeColors) {
                    return DropdownMenuItem<SnakeColors>(
                      value: snakeColors,
                      child: Container(
                        width: MediaQuery.of(context).size.width * .75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              snakeColors.name,
                              style: TextStyle(
                                  color: (snakeColors.color == Colors.white70)
                                      ? Colors.grey[700]
                                      : snakeColors.color),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5000),
                                  border: Border.all(
                                      color: Colors.black, width: .5)),
                              child: CircleAvatar(
                                backgroundColor: snakeColors.color,
                                radius: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

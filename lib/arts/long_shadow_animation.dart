import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math';

class LongShadowAnimationPage extends StatefulWidget {
  LongShadowAnimationPage({Key key}) : super(key: key);

  @override
  _LongShadowAnimationPageState createState() =>
      _LongShadowAnimationPageState();
}

class _LongShadowAnimationPageState extends State<LongShadowAnimationPage>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;

  List<Box> boxes = [];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(microseconds: 100),
      vsync: this,
    );
    // Add listener
    animationController.addListener(() {
      setState(() {});
    });

    // Repeat the animation
    animationController.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    List.generate(20, (index) {
      boxes.add(Box(
          random: Random(),
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height)));
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Long Shadow Animation'),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 2,
                      colors: [Colors.green[500], Colors.blue],
                      stops: [0.009, 0.9]),
                ),
              ),
              LongShadowAnimation(
                  light: Light(
                      x: MediaQuery.of(context).size.width / 2,
                      y: MediaQuery.of(context).size.height / 2),
                  boxes: boxes),
            ],
          ),
        ),
      ),
    );
  }
}

class LongShadowAnimation extends StatelessWidget {
  const LongShadowAnimation({@required this.light, this.boxes});

  final Light light;
  final List<Box> boxes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _LongShadowAnimationPainter(
              light: light, size: MediaQuery.of(context).size, boxes: boxes),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock hand.
class _LongShadowAnimationPainter extends CustomPainter {
  math.Random random = math.Random();

  Light light;
  List<Box> boxes;

  _LongShadowAnimationPainter({@required this.light, Size size, this.boxes});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < boxes.length; i++) {
      boxes[i].rotate();
      boxes[i].drawShadow(canvas, light);
    }

    for (var i = 0; i < boxes.length; i++) {
      collisionDetection(i);
      boxes[i].draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_LongShadowAnimationPainter oldDelegate) {
    return true;
  }

  void collisionDetection(int b) {
    for (var i = boxes.length - 1; i >= 0; i--) {
      if (i != b) {
        var dx =
            (boxes[b].x + boxes[b].halfSize) - (boxes[i].x + boxes[i].halfSize);
        var dy =
            (boxes[b].y + boxes[b].halfSize) - (boxes[i].y + boxes[i].halfSize);
        var d = math.sqrt(dx * dx + dy * dy);
        if (d < boxes[b].halfSize + boxes[i].halfSize) {
          boxes[b].halfSize =
              boxes[b].halfSize > 1 ? boxes[b].halfSize -= 1 : 1;
          boxes[i].halfSize =
              boxes[i].halfSize > 1 ? boxes[i].halfSize -= 1 : 1;
        }
      }
    }
  }
}

class Box {
  double halfSize;
  double x;
  double y;
  double r;
  double shadowLength;
  Color color;
  final math.Random random;
  Size size;
  List<String> colors = ["f5c156", "e6616b", "5cd3ad"];

  Box({this.random, this.size}) {
    halfSize = (math.Random().nextDouble() * 100) + 1;
    x = (math.Random().nextDouble() * size.width) + 1;
    y = (math.Random().nextDouble() * size.height) + 1;
    r = math.Random().nextDouble() * math.pi;
    shadowLength = 1000;
    color = Hex.intToColor(Hex.stringToInt(
        colors[(math.Random().nextDouble() * colors.length).floor()]));
  }

  List<Point<double>> getDots() {
    double full = (math.pi * 2) / 4;

    Point<double> p1 =
        Point<double>(x + halfSize * math.sin(r), y + halfSize * math.cos(r));
    Point<double> p2 = Point<double>(
        x + halfSize * math.sin(r + full), y + halfSize * math.cos(r + full));
    Point<double> p3 = Point<double>(x + halfSize * math.sin(r + full * 2),
        y + halfSize * math.cos(r + full * 2));
    Point<double> p4 = Point<double>(x + halfSize * math.sin(r + full * 3),
        y + halfSize * math.cos(r + full * 3));

    return [p1, p2, p3, p4];
  }

  void rotate() {
    var speed = (60 - halfSize) / 20;
    r += speed * 0.002;
    x += speed;
    y += speed;
  }

  void draw(Canvas canvas, Size size) {
    List<Point<double>> dots = getDots();

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    Path path = Path();

    path.moveTo(dots[0].x, dots[0].y);
    path.lineTo(dots[1].x, dots[1].y);
    path.lineTo(dots[2].x, dots[2].y);
    path.lineTo(dots[3].x, dots[3].y);

    canvas.drawPath(path, paint);

    if (y - halfSize > size.height) {
      y -= size.height + 100;
    }

    if (x - halfSize > size.width) {
      x -= size.width + 100;
    }
  }

  void drawShadow(Canvas canvas, Light light) {
    List<Point<double>> dots = getDots();
    List<double> angles = [];
    List<ShadowPoint> points = [];

    for (Point dot in dots) {
      double angle = math.atan2(light.y - dot.y, light.x - dot.x);
      var endX = dot.x + shadowLength * math.sin(-angle - math.pi / 2);
      var endY = dot.y + shadowLength * math.cos(-angle - math.pi / 2);
      angles.add(angle);
      points.add(
          ShadowPoint(endX: endX, endY: endY, startX: dot.x, startY: dot.y));
    }

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Hex.intToColor(Hex.stringToInt("2c343f"));
    Path path = Path();

    for (var i = points.length - 1; i >= 0; i--) {
      var n = i == 3 ? 0 : i + 1;

      path.moveTo(points[i].startX, points[i].startY);
      path.lineTo(points[n].startX, points[n].startY);
      path.lineTo(points[n].endX, points[n].endY);
      path.lineTo(points[i].endX, points[i].endY);

      canvas.drawPath(path, paint);
    }
  }
}

class ShadowPoint {
  final double endX;
  final double endY;
  final double startX;
  final double startY;

  ShadowPoint({this.endX, this.endY, this.startX, this.startY});
}

class Light {
  final double x;
  final double y;

  Light({this.x, this.y});
}

class Hex {
  //Hex Number To Color
  static Color intToColor(int hexNumber) => Color.fromARGB(
      255,
      (hexNumber >> 16) & 0xFF,
      ((hexNumber >> 8) & 0xFF),
      (hexNumber >> 0) & 0xFF);

  //String To Hex Number
  static int stringToInt(String hex) => int.parse(hex, radix: 16);

  //String To Color
  static String colorToString(Color color) =>
      _colorToString(color.red.toRadixString(16)) +
      _colorToString(color.green.toRadixString(16)) +
      _colorToString(color.blue.toRadixString(16));
  static String _colorToString(String text) =>
      text.length == 1 ? "0" + text : text;

  //Subste
  static String textSubString(String text) {
    if (text == null) return null;

    if (text.length < 6) return null;

    if (text.length == 6) return text;

    return text.substring(text.length - 6, 6);
  }
}

import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';

class ColorTest extends StatefulWidget {
  ColorTest({Key key}) : super(key: key);

  @override
  _ColorTestState createState() => _ColorTestState();
}

class _ColorTestState extends State<ColorTest> {
  Offset point = Offset(0, 0);
  bool done = false;
  Color newColor;
  int time = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        if (time >= 100)
          time = 0;
        else
          time += 1;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!done) {
      // or else you end up creating multiple instances in this case.
      newColor =
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

      done = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Color Test'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTapDown: (b) {
          setState(() {
            point = b.globalPosition;
          });
        },
        onForcePressUpdate: (b) {
          setState(() {
            point = b.globalPosition;
          });
        },
        onPanDown: (b) {
          setState(() {
            point = b.globalPosition;
          });
        },
        onPanUpdate: (b) {
          setState(() {
            point = b.globalPosition;
          });
        },
        child: Container(
            child: Center(
          child: Container(
            child: CustomPaint(
              painter: CustomPainer(strokeColor: newColor),
              child: Container(
                height: screenHeight(context),
                width: screenWidth(context),
              ),
            ),
          ),
        )),
      ),
    );
  }
}

double screenHeight(BuildContext context, {double percent = 1}) =>
    MediaQuery.of(context).size.height * percent;

double screenWidth(BuildContext context, {double percent = 1}) =>
    MediaQuery.of(context).size.width * percent;

class CustomPainer extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  double w;
  double h;

  List<Body> arr = [];
  var i = 0;

  CustomPainer({
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.3,
    this.paintingStyle = PaintingStyle.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    w = size.width;
    h = size.height;
    while (arr.length < (w * h / 810)) {
      arr.add(Body(
          x: ((Random().nextDouble() * w).toInt() | 0),
          y: (Random().nextDouble() * h).toInt() | 0,
          vx: 0,
          vy: 0));
    }
    go(canvas);
  }

  _x(foo) {
    return sin(foo.y / 45) / 0.3;
  }

  _y(foo) {
    return sin(foo.x / 45) / 0.3;
  }

  upd(Canvas canvas) {
    var n = arr[i];
    n.x += n.vx;
    n.y += n.vy;
    if (n.x < 0) {
      n.x = (w + n.x).toInt();
    } else if (n.x >= w) {
      n.x -= w.toInt();
    }

    if (n.y < 0) {
      n.y = (h + n.y).toInt();
    } else if (n.y >= h) {
      n.y -= h.toInt();
    }

    n.vy = _y(n);
    n.vx = _x(n);
  }

  draw(Canvas canvas) {
    var n = arr[i];
    // HSLColor col = HSLColor.fromAHSL(1, i/10, 0.9, 0.6);

    Paint line = Paint()
      ..style = PaintingStyle.fill
      ..color =
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
      ..strokeCap = StrokeCap.round;

    var m = Offset(n.x.toDouble(), n.y.toDouble());

    canvas.drawArc(
        Rect.fromCircle(
          center: m,
          radius: 15 / max((n.vx * n.vx + n.vy * n.vy), 0.5),
        ),
        0,
        2 * pi,
        false,
        line);

    //inner rings

    var g = Offset(
      n.x.toDouble(),
      n.y.toDouble(),
    );

    canvas.drawArc(
        Rect.fromCircle(
          center: g,
          radius: 8 / max((n.vx * n.vx + n.vy * n.vy), 0.8),
        ),
        0,
        2 * pi,
        false,
        line);
  }

  go(Canvas canvas) {
    for (i = 0; i < (w * h / 810); i++) {
      upd(canvas);
      draw(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainer oldDelegate) {
    return true;
  }
}

class Body {
  num x, y, vx, vy;

  Body({this.x, this.y, this.vx, this.vy});
}

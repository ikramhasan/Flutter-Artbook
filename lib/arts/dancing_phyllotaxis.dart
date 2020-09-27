import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  double tick;

  var zF = 340;
  var size = 3;
  var center = 0;
  get r => this.zF / 2.1;

  Map<String, num> option = {"size": 1000, "zFactor": 0, "speed": 0.2};
  List<int> sqAr = [];
  ArtPainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.3,
    this.tick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 500; i++) {
      sqAr.add(i);
    }
    animate(canvas, size);
    canvas.restore();
  }

  animate(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    for (var i = 0; i < sqAr.length; i++) {
      setFlo(tick, i, canvas);
    }
    sqAr = List.generate(1000, (x) => x + 1);
  }

  setFlo(value, i, Canvas canvas) {
    var j = pi - (pi / option['size'] * i);
    var b = pi * value / option['size'] * i;
    var zF = this.zF / (this.zF + option['zFactor'] - this.r);
    var zz = this.center - zF * cos(j) * this.size;
    var x = this.center - this.r * sin(j) * cos(b);
    var y = this.center - this.r * sin(j) * sin(b);
    var z = (zz);
    Paint line = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(
          center: Offset(x, y),
          radius: z / 2,
        ),
        0,
        pi * 2,
        false,
        line);
  }

  @override
  bool shouldRepaint(ArtPainter oldDelegate) {
    return true;
  }
}

class DancingPhyllotaxis extends StatefulWidget {
  DancingPhyllotaxis({Key key}) : super(key: key);

  @override
  DancingPhyllotaxisState createState() => DancingPhyllotaxisState();
}

class DancingPhyllotaxisState extends State<DancingPhyllotaxis> {
  var tick = 79.78;
  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 5), (t) {
      setState(() {
        tick += (0.7 * 0.2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Dancing Phyllotaxis',
          style: GoogleFonts.quicksand(),),
        centerTitle: true,
      ),
      body: Container(
          child: Center(
        child: Container(
          child: CustomPaint(
            painter: ArtPainter(tick: tick),
            child: Container(
              height: 1500,
              width: 1500,
            ),
          ),
        ),
      )),
    );
  }
}

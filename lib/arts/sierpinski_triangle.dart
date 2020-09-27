import 'dart:math' as math;
import 'dart:ui';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:google_fonts/google_fonts.dart';

const double kSize = 150.0;

class Sierpinski extends StatefulWidget {
  Sierpinski({Key key}) : super(key: key);

  @override
  _SierpinskiState createState() => _SierpinskiState();
}

class _SierpinskiState extends State<Sierpinski> {
  SierpinskiTriangle simulation;

  @override
  void initState() {
    super.initState();
    simulation = SierpinskiTriangle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        centerTitle: true,
        title: Text('Sierpinski Triangle',
          style: GoogleFonts.quicksand(),),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AboutDialog(
                  children: [
                    SelectableText('TODO'),
                    Container(),
                    Center(
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.open_in_new,
                          color: Colors.black45,
                        ),
                        label: Text(
                          'Follow me on Twitter',
                          style: GoogleFonts.quicksand(color: Colors.black54),
                        ),
                        onPressed: () {
                          html.window.open(
                              'https://twitter.com/OrestesGaolin', 'Twitter');
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: simulation,
        builder: (context, child) => Stack(
          children: [
            Center(
              child: CustomPaint(
                painter: SierpinskiPainter(simulation.paths),
                child: Container(
                  height: MediaQuery.of(context).size.shortestSide,
                  width: MediaQuery.of(context).size.shortestSide,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SierpinskiPainter extends CustomPainter {
  final List<Path> paths;
  final trianglePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;
  SierpinskiPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, size.height / 10);
    final scale = size.shortestSide / kSize;
    canvas.scale(scale);
    for (var path in paths) {
      canvas.drawPath(path, trianglePaint);
    }
  }

  num map(num value, num istart, num istop, num ostart, num ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SierpinskiTriangle extends ChangeNotifier {
  final List<Path> paths = [];

  SierpinskiTriangle() {
    start(kSize, paths);
  }

  void start(double sz, List<Path> paths) {
    paths.clear();

    final midPoint = Offset(sz / 2, sz / 2);
    final iterations = 6;
    final rInner = sz / 6 * math.sqrt(3);
    final rOuter = sz / 3 * math.sqrt(3);

    final pointA = Offset(midPoint.dx - sz / 2, midPoint.dy + rInner);
    final pointB = Offset(midPoint.dx + sz / 2, midPoint.dy + rInner);
    final pointC = Offset(midPoint.dx, midPoint.dy - rOuter);
    sierpinski(pointA, pointB, pointC, iterations);
  }

  void sierpinski(Offset pointA, Offset pointB, Offset pointC, int d) async {
    if (d > 0) {
      var pointAx = (pointB.dx + pointC.dx) / 2;
      var pointAy = (pointB.dy + pointC.dy) / 2;

      var pointBx = (pointA.dx + pointC.dx) / 2;
      var pointBy = (pointA.dy + pointC.dy) / 2;

      var pointCx = (pointA.dx + pointB.dx) / 2;
      var pointCy = (pointA.dy + pointB.dy) / 2;

      final a = Offset(pointAx, pointAy);
      final b = Offset(pointBx, pointBy);
      final c = Offset(pointCx, pointCy);

      var d2 = d - 1;
      await Future.delayed(Duration(milliseconds: d2 * 100));
      sierpinski(pointA, b, c, d2);
      await Future.delayed(Duration(milliseconds: d2 * 200));
      sierpinski(c, a, pointB, d2);
      await Future.delayed(Duration(milliseconds: d2 * 300));
      sierpinski(b, a, pointC, d2);
    } else {
      final path = Path();
      path.moveTo(pointA.dx, pointA.dy);
      path.lineTo(pointB.dx, pointB.dy);
      path.lineTo(pointC.dx, pointC.dy);
      path.lineTo(pointA.dx, pointA.dy);
      paths.add(path);
      notifyListeners();
    }
  }
}

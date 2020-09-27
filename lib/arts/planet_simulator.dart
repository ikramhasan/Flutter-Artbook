import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlanetSimulator();
  }
}

class PlanetSimulator extends StatefulWidget {
  @override
  _PlanetSimulatorState createState() => _PlanetSimulatorState();
}

class _PlanetSimulatorState extends State<PlanetSimulator> {
  List<Body> gravityBodies = [
    Body(Offset(500, 400), Offset(0, 0), gravity: 5000.0),
    Body(Offset(1000, 400), Offset(0, 0), gravity: 5000.0),
  ];
  List<Body> normalBodies = [
    Body(Offset(500, 100), Offset(3, 0)),
    Body(Offset(500, 50), Offset(3, 0)),
    Body(Offset(500, 50), Offset(-2, 0)),
    Body(Offset(1000, 50), Offset(-2.5, 0)),
    Body(Offset(100, 150), Offset(-1, 0)),
    Body(Offset(1000, 245), Offset(-3, 0)),
    Body(Offset(1000, 60), Offset(-2, 0)),
  ];

  List<List<Remnant>> pastEntries = [];

  Body pointInConsideration;
  Offset velocityPoint;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _calculateNewPositions();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Planet Simulator',
          style: GoogleFonts.quicksand(),),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTapDown: (event) {
          pointInConsideration = Body(event.globalPosition, Offset.zero);
          setState(() {});
        },
        onTapUp: (event) {
          normalBodies.add(pointInConsideration);
          pointInConsideration = null;
          velocityPoint = null;
          setState(() {});
        },
        onPanUpdate: (details) {
          if (pointInConsideration != null)
            pointInConsideration.velocity =
                (pointInConsideration.center - details.globalPosition) / 20;
          velocityPoint = details.globalPosition;
          setState(() {});
        },
        onPanEnd: (event) {
          if (pointInConsideration != null) {
            normalBodies.add(pointInConsideration);
            pointInConsideration = null;
            velocityPoint = null;
            setState(() {});
          }
        },
        child: Stack(
          children: <Widget>[
            Container(
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: SpacePainter(gravityBodies, normalBodies, pastEntries),
              ),
            ),
            if (pointInConsideration != null)
              Positioned(
                left: pointInConsideration.center.dx - 5.0,
                top: pointInConsideration.center.dy - 5.0,
                child: CircleAvatar(
                  maxRadius: 10.0,
                  backgroundColor: pointInConsideration.color,
                ),
              ),
            if (velocityPoint != null && pointInConsideration != null)
              Positioned(
                left: velocityPoint.dx -
                    (pointInConsideration.center - velocityPoint).distance / 2,
                top: velocityPoint.dy -
                    (pointInConsideration.center - velocityPoint).distance / 2,
                child: Transform.rotate(
                  angle:
                      (pointInConsideration.center - velocityPoint).direction,
                  child: Icon(
                    Icons.arrow_forward,
                    size:
                        (pointInConsideration.center - velocityPoint).distance,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _calculateNewPositions() {
    List<Body> newNormalList = [];

    normalBodies.forEach((normalElement) {
      var deltaX = 0.0;
      var deltaY = 0.0;

      gravityBodies.forEach((gravityElement) {
        var dx = gravityElement.center.dx - normalElement.center.dx;
        var dy = gravityElement.center.dy - normalElement.center.dy;

        var distance = sqrt(pow(dx, 2) + pow(dy, 2));

        var increase = gravityElement.gravity / pow(distance, 2);

        deltaX += increase * (dx / (dx.abs() + dy.abs()));
        deltaY += increase * (dy / (dx.abs() + dy.abs()));
      });
      normalElement.velocity += Offset(deltaX, deltaY);

      normalElement.center = normalElement.center + normalElement.velocity;

      if (!(normalElement.center.dx.abs() > 5000 ||
          normalElement.center.dy.abs() > 5000)) {
        newNormalList.add(normalElement);
      }
    });

    if (pastEntries.length == 50) {
      pastEntries.removeAt(0);
    }
    normalBodies = newNormalList;
    pastEntries
        .add(normalBodies.map((e) => Remnant(e.center, e.color)).toList());

    gravityBodies.forEach((element) {
      element.center = element.center + element.velocity;
    });
  }
}

class SpacePainter extends CustomPainter {
  List<Body> gravityBodies;
  List<Body> normalBodies;
  List<List<Remnant>> pastEntries;

  SpacePainter(this.gravityBodies, this.normalBodies, this.pastEntries);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPaint(Paint()..color = Color(0xFF2D2F41));

    for (var body in gravityBodies) {
      canvas.drawCircle(body.center, 10.0, Paint()..color = Colors.black);
    }

    for (var body in normalBodies) {
      canvas.drawCircle(body.center, 10.0, Paint()..color = body.color);
    }

    for (int i = 0; i < 50; i++) {
      if (pastEntries.length <= i + 1) {
        continue;
      }
      var bodies = pastEntries[i];
      for (var body in bodies) {
        canvas.drawCircle(
            body.offset, 1.5 + (i * 0.03), Paint()..color = body.color);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Body {
  Offset center;
  Offset velocity;
  double gravity;
  Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];

  Body(this.center, this.velocity, {this.gravity = 0.0});
}

class Remnant {
  Offset offset;
  Color color;

  Remnant(this.offset, this.color);
}

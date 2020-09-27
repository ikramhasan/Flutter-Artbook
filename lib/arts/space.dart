import 'package:flutter/material.dart';
import 'dart:math';

const int maxStar = 50;
const double maxRadius = 3;
const double speedFactor = 0.5;

class Space extends StatefulWidget {
  @override
  _SpaceState createState() => _SpaceState();
}

class _SpaceState extends State<Space> {
  Size size;
  List<Circle> circles = [];

  @override
  void didChangeDependencies() {
    size = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );
    circles.clear();
    for (int index = 0; index < maxStar; index++) {
      circles.add(Circle(size));
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.scheduleFrameCallback((_) {
      setState(() {
        circles.forEach((circle) {
          circle.update();
        });
      });
    });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         circles.forEach((circle) {
//           circle.update();
//         });
//       });
//     });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Space'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: CustomPaint(
          size: size,
          painter: SpacePainter(circles),
        ),
      ),
    );
  }
}

class SpacePainter extends CustomPainter {
  final List<Circle> circles;
  SpacePainter(this.circles);
  @override
  void paint(Canvas canvas, Size size) {
    circles.forEach((circle) {
      canvas.drawCircle(
        circle.getCircleOffset,
        circle.getRadius,
        circle.getCircleShadowPaint,
      );
      canvas.drawCircle(
        circle.getCircleOffset,
        circle.getRadius,
        circle.getCirclePaint,
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Circle {
  Paint _circlePaint, _circleShadowPaint;
  Offset _circleOffset;
  double _radius, _canvasWidth, _canvasHeight, _x, _y, _dx, _dy;

  Circle(Size size) {
    Random random = Random();
    _canvasWidth = size.width;
    _canvasHeight = size.height;
    _radius = random.nextDouble() * maxRadius + 1;

    _x = random.nextDouble() * (_canvasWidth - _radius * 2) + _radius;
    _y = random.nextDouble() * (_canvasHeight - _radius * 2) + _radius;

    if (_radius > 2) {
      _dx = (random.nextDouble() - speedFactor) * 2;
      _dy = (random.nextDouble() - speedFactor) * 2;
    } else {
      _dx = random.nextDouble() - speedFactor;
      _dy = random.nextDouble() - speedFactor;
    }

    _circleOffset = Offset(_x, _y);

    _circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _circleShadowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        Shadow.convertRadiusToSigma(_radius + 5),
      );
  }

  void update() {
    if (_x + _radius > _canvasWidth || _x - _radius < 0) {
      _dx = -_dx;
    }

    if (_y + _radius > _canvasHeight || _y - _radius < 0) {
      _dy = -_dy;
    }

    _x += _dx;
    _y += _dy;

    _circleOffset = Offset(_x, _y);
  }

  Offset get getCircleOffset => _circleOffset;

  Paint get getCirclePaint => _circlePaint;

  Paint get getCircleShadowPaint => _circleShadowPaint;

  double get getRadius => _radius;
}

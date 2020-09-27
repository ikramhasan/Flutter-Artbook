/// Based on an original work and concept by Dave Whyte
/// https://twitter.com/beesandbombs/status/1254914806714335232

import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

const int rings = 5;
const int turnDuration = 1500;

const bool fitScreen = false;

const bool optimizeWhiteStrokes = true;

const bool whiteAntiAlias = false;
const bool componentsAntiAlias = false;

const BlendMode blendMode = BlendMode.screen;
const double whiteBlurSigma = 0;
const double componentsBlurSigma = 0;

const double radius = 20.0;
const double strokeWidth = 3.0;

const numberOfTurnBeforeSpread = 2;
const spreadRadiusFactor = 2 / 3;
const spreadHorizontalOffsetFactor = 0.0;
const spreadVerticalOffsetFactor = 1.5;

const baseRingAngleOffsetFactor = 0.0;
const ringAngleOffsetFactor = 0.0;
const circleAngleOffsetFactor = 2.5;

class AnimatedCircles extends StatefulWidget {
  @override
  _AnimatedCirclesState createState() => _AnimatedCirclesState();
}

class _AnimatedCirclesState extends State<AnimatedCircles>
    with SingleTickerProviderStateMixin {
  int _time = 0;
  Ticker _ticker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Animated Circles',
          style: GoogleFonts.quicksand(),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).canvasColor,
          child: Builder(builder: (context) {
            final size = MediaQuery.of(context).size;
            return FractionallySizedBox(
              widthFactor: fitScreen ? 1.0 : size.shortestSide / size.width,
              heightFactor: fitScreen ? 1.0 : size.shortestSide / size.height,
              child: CustomPaint(
                painter: CirclePainter(_time),
                isComplex: true,
                willChange: true,
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(
        (Duration elapsed) => setState(() => _time = elapsed.inMilliseconds));
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  final int _time;

  CirclePainter(this._time);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final frame = _time / turnDuration * 2 * pi;
    final double scale = _computeScale(size, radius, rings - 1);
    final Rect clipRect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final Rect cullRect = Rect.fromCenter(
        center: Offset.zero,
        width: (size.width + 2 * radius) / scale,
        height: (size.height + 2 * radius) / scale);

    canvas.clipRect(clipRect, doAntiAlias: false);
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, scale);

    final circleCount = Hex.spiralHexCount(rings);
    int circleSpiralIndex = 0;
    for (int ring = 0; ring <= rings; ++ring) {
      final ringProgress = ring / rings;
      final angle = frame;
      final spreadDelay = 2 * pi / numberOfTurnBeforeSpread * ringProgress;
      final spread =
          max(sin(frame / (2 * numberOfTurnBeforeSpread) - spreadDelay), 0.0);
      final strokeRadius =
          ui.lerpDouble(radius, radius * spreadRadiusFactor, spread);
      final baseRingAngleOffset =
          (ringProgress * baseRingAngleOffsetFactor * pi);
      final circleRingCount = Hex.ringHexCount(ring);
      Hex.ring(ring)
          .map((hex) => hex.toOffset(const Size(radius, radius)))
          .where((position) => cullRect.contains(position))
          .forEachIndexed((circleRingIndex, position) {
        final ringAngleOffset =
            circleRingIndex / circleRingCount * ringAngleOffsetFactor * pi;
        final circleAngleOffset =
            circleSpiralIndex / circleCount * circleAngleOffsetFactor * pi;

        canvas.drawStrokes(
            position.dx,
            position.dy,
            strokeRadius,
            strokeWidth,
            angle + baseRingAngleOffset + ringAngleOffset + circleAngleOffset,
            spread);

        ++circleSpiralIndex;
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double _computeScale(Size size, double radius, int rings) {
    double horizontalScale =
        size.width / (Hex.horizontalSpacingBasis * radius * (rings + 1));
    double verticalScale =
        size.height / (Hex.verticalSpacingBasis * radius * (rings * 2 + 1));
    return max(horizontalScale, verticalScale);
  }
}

extension on Canvas {
  void drawStrokes(double cx, double cy, double radius, double width,
      double angle, double spread) {
    final stroke = _createStroke(0, 0, radius, width);
    if (optimizeWhiteStrokes && spread == 0.0) {
      _drawPath(stroke, cx, cy, angle,
          _createPaint(Colors.white, whiteAntiAlias, whiteBlurSigma));
    } else {
      final horizontalSpreadOffset =
          ui.lerpDouble(0, radius * spreadHorizontalOffsetFactor, spread);
      final verticalSpreadOffset =
          ui.lerpDouble(0, radius * spreadVerticalOffsetFactor, spread);
      _drawPath(
          stroke,
          cx - horizontalSpreadOffset,
          cy - verticalSpreadOffset,
          angle,
          _createPaint(Colors.red, componentsAntiAlias, componentsBlurSigma));
      _drawPath(stroke, cx, cy, angle,
          _createPaint(Colors.green, componentsAntiAlias, componentsBlurSigma));
      _drawPath(
          stroke,
          cx + horizontalSpreadOffset,
          cy + verticalSpreadOffset,
          angle,
          _createPaint(Colors.blue, componentsAntiAlias, componentsBlurSigma));
    }
  }

  Path _createStroke(double cx, double cy, double radius, double width) =>
      Path()..addStroke(cx, cy, radius, width);

  void _drawPath(Path path, double x, double y, double angle, Paint paint) {
    save();
    translate(x, y);
    rotate(angle);
    drawPath(path, paint);
    restore();
  }

  Paint _createPaint(Color color, bool antiAlias, double blurSigma) => Paint()
    ..isAntiAlias = antiAlias
    ..maskFilter =
        blurSigma > 0.0 ? MaskFilter.blur(BlurStyle.solid, blurSigma) : null
    ..color = color
    ..blendMode = color == Colors.white ? BlendMode.srcOver : blendMode;
}

extension on Path {
  void addStroke(double cx, double cy, double radius, double width) {
    final diameter = 2 * radius;
    final dx = diameter * 0.05;
    final dy = radius * 4.0 / 3.0;
    final x0 = cx - radius;
    final y0 = cy;
    final x1 = x0 + dx;
    final y1 = y0 + dy;
    final x2 = x0 + diameter - dx;
    final y2 = y0 + dy;
    final x3 = x0 + diameter;
    final y3 = y0;
    final xWidth = width / 2.0;
    final yWidth = width * 3 / 4.0;

    this
      ..moveTo(x0, y0)
      ..cubicTo(x1, y1, x2, y2, x3, y3)
      ..cubicTo(x2 + xWidth, y2, x1 - xWidth, y1 + yWidth, x0 - width, y0)
      ..close();
  }
}

extension IterableExtension<E> on Iterable<E> {
  Iterable<R> mapIndexed<R>(R Function(int index, E element) transform) {
    int i = 0;
    return map((E e) => transform(i++, e));
  }

  void forEachIndexed(void f(int index, E element)) {
    int i = 0;
    return forEach((E e) => f(i++, e));
  }
}

class Hex {
  static const Hex zero = const Hex.axial(0, 0);
  static const _directions = [
    const Hex.axial(1, 0),
    const Hex.axial(1, -1),
    const Hex.axial(0, -1),
    const Hex.axial(-1, 0),
    const Hex.axial(-1, 1),
    const Hex.axial(0, 1)
  ];
  static const double sqrt3 = 1.7320508075688772935;
  static const Offset qBasis = const Offset(sqrt3, 0);
  static const Offset rBasis = const Offset(sqrt3 / 2, 1.5);
  static const double horizontalSpacingBasis = sqrt3;
  static const double verticalSpacingBasis = 1.5;

  final int q;
  final int r;

  const Hex.axial(this.q, this.r);

  Hex operator +(Hex other) => Hex.axial(q + other.q, r + other.r);

  Hex scale(int scale) => Hex.axial(q * scale, r * scale);

  static Hex directionHex(int direction) => _directions[direction % 6];

  static int ringHexCount(int radius) {
    assert(!radius.isNegative, "radius should be positive");
    if (radius == 0) return 1;
    return 6 * radius;
  }

  static int spiralHexCount(int radius) {
    assert(!radius.isNegative, "radius should be positive");
    return radius * (radius + 1) * 3 + 1;
  }

  static Iterable<Hex> ring(int radius, {Hex center = zero}) sync* {
    assert(!radius.isNegative, "radius should be positive");
    if (radius == 0) {
      yield center;
      return;
    }
    Hex currentHex = center + directionHex(4).scale(radius);
    for (int direction = 0; direction < 6; ++direction) {
      for (int i = 0; i < radius; ++i) {
        yield currentHex;
        currentHex = currentHex + directionHex(direction);
      }
    }
  }

  Offset toOffset(Size size, {Offset origin = Offset.zero}) =>
      (qBasis * q.toDouble() + rBasis * r.toDouble())
          .scale(size.width, size.height) +
      origin;
}

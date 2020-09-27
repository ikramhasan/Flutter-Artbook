import 'dart:async';

import 'package:flutter/material.dart';

class AppColors {
  static Color lines = const Color(0xFF73D1CC);
  static Color background = const Color(0xFF100F43);
  static Color glow = const Color(0xFF125AA1);
}

class BarBar extends StatefulWidget {
  const BarBar({Key key}) : super(key: key);

  @override
  _BarBarState createState() => _BarBarState();
}

class _BarBarState extends State<BarBar> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _progressAnimation;
  DateTime _current, _previous;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.decelerate),
    );
    _current = _previous = DateTime.now();
    _updateTime();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _previous = _current;
      _current = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _current.millisecond),
        _updateTime,
      );
      _animationController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('BarBar Clock'),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.glow.withOpacity(0.7),
                  blurRadius: 500.0,
                ),
                BoxShadow(
                  color: AppColors.background,
                  blurRadius: 100.0,
                ),
                BoxShadow(
                  color: AppColors.glow.withOpacity(0.1),
                  blurRadius: 500.0,
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                clipBehavior: Clip.none,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: ClockPainter(
                    previous: _previous,
                    current: _current,
                    progress: _progressAnimation,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  ClockPainter({
    @required this.previous,
    @required this.current,
    @required this.progress,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final DateTime previous;
  final DateTime current;

  @override
  void paint(Canvas canvas, Size size) {
    final barSpaceWidth = size.width / 39.6;
    final spaceWidth = barSpaceWidth * 0.75;
    final barWidth = barSpaceWidth * 0.25;
    final digitHeight = size.height * 0.44;
    final centerY = ((size.height - digitHeight) / 2);
    final barPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth
      ..color = AppColors.lines;
    final digits = Digits.getTime(previous, current, progress.value);
    for (var bar = 0; bar < 39; bar++) {
      final startX = barSpaceWidth * bar + spaceWidth;
      for (final item in digits.where((item) => item.index == bar)) {
        final top = Offset(
          startX + barWidth * 0.5,
          item.startY == 0.0 ? 0.0 : item.startY * digitHeight + centerY,
        );
        final bot = Offset(
          startX + barWidth * 0.5,
          item.endY == 1.0 ? size.height : item.endY * digitHeight + centerY,
        );
        canvas.drawLine(top, bot, barPaint);
      }
    }
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return oldDelegate.previous != previous ||
        oldDelegate.current != current ||
        oldDelegate.progress != progress;
  }
}

class Bar implements Comparable<Bar> {
  const Bar(this.index, {@required this.startY, @required this.endY});

  final int index;
  final double startY;
  final double endY;

  Bar copy({int index, double startY, double endY}) {
    return Bar(
      index ?? this.index,
      startY: startY ?? this.startY,
      endY: endY ?? this.endY,
    );
  }

  @override
  int compareTo(Bar other) => startY.compareTo(other.startY);
}

class Digits {
  static List<Bar> getTime(DateTime prev, DateTime curr, double progress) {
    final oldHour1 = prev.hour ~/ 10;
    final oldHour2 = prev.hour % 10;
    final newHour1 = curr.hour ~/ 10;
    final newHour2 = curr.hour % 10;

    final oldMinute1 = prev.minute ~/ 10;
    final oldMinute2 = prev.minute % 10;
    final newMinute1 = curr.minute ~/ 10;
    final newMinute2 = curr.minute % 10;

    final hourFirst = _getDigitTransition(oldHour1, newHour1, progress);
    final hourSecond = _getDigitTransition(oldHour2, newHour2, progress);
    final minuteFirst = _getDigitTransition(oldMinute1, newMinute1, progress);
    final minuteSecond = _getDigitTransition(oldMinute2, newMinute2, progress);

    // Build a list where each digit's bar has location which is relative to
    // the start of clock face canvas (counted in bars from 0 to 39)
    final digits = <Bar>[
      ...hourFirst.map((i) => i.copy(index: i.index + 4)),
      ...hourSecond.map((i) => i.copy(index: i.index + 11)),
      ..._data[10].map((i) => i.copy(index: i.index + 19)),
      ...minuteFirst.map((i) => i.copy(index: i.index + 22)),
      ...minuteSecond.map((i) => i.copy(index: i.index + 29)),
    ];

    // Add missing vertical bars
    for (var bar = 0; bar < 39; bar++) {
      if (!digits.any((i) => i.index == bar)) {
        digits.add(Bar(bar, startY: 0.0, endY: 1.0));
      }
    }
    return digits;
  }

  static List<Bar> _getDigitTransition(int from, int to, double progress) {
    final digitFrom = _data[from];
    final digitTo = _data[to];

    if (progress == 0.0) return digitFrom;
    if (progress == 1.0) return digitTo;

    final result = <Bar>[];
    for (var bar = 0; bar < 6; bar++) {
      final barsPositionFrom = digitFrom.where((it) => it.index == bar);
      final barsPositionTo = digitTo.where((it) => it.index == bar);

      // Calculate top and bottom bars
      final topBarOld = barsPositionFrom.firstWhere((it) => it.startY == 0);
      final topBarNew = barsPositionTo.firstWhere((it) => it.startY == 0);
      final bottomBarOld = barsPositionFrom.firstWhere((it) => it.endY == 1);
      final bottomBarNew = barsPositionTo.firstWhere((it) => it.endY == 1);
      _transition(result, progress, topBarOld, topBarNew);
      _transition(result, progress, bottomBarOld, bottomBarNew);

      // Middle bar is a bar that is not drawn from top to bottom
      final barFrom =
          barsPositionFrom.where((it) => it.startY > 0 && it.endY < 1);
      final barTo = barsPositionTo.where((it) => it.startY > 0 && it.endY < 1);
      final lengthOld = barFrom.length;
      final lengthNew = barTo.length;

      // Nothing to transform
      if (lengthOld == 0 && lengthNew == 0) continue;

      // Create transformations based on number of old and new middle bars
      if (lengthOld == 0 && lengthNew == 1) {
        _transition(result, progress, _barFrom(barTo.first), barTo.first);
      } else if (lengthOld == 1 && lengthNew == 0) {
        _transition(result, progress, barFrom.first, _barFrom(barFrom.first));
      } else if (lengthOld == 1 && lengthNew == 1) {
        _transition(result, progress, barFrom.first, barTo.first);
      } else if (lengthOld == 1 && lengthNew == 2) {
        _transition(result, progress, barFrom.first, barTo.elementAt(0));
        _transition(result, progress, barFrom.first, barTo.elementAt(1));
      } else if (lengthOld == 2 && lengthNew == 1) {
        final newBar = barTo.first;
        final oldBars = barFrom.toList()..sort();
        final newFrom1 = _barFrom(newBar, startY: newBar.startY);
        _transition(result, progress, oldBars[0], newFrom1);
        final newFrom2 = _barFrom(newBar, endY: newBar.endY);
        _transition(result, progress, oldBars[1], newFrom2);
      } else if (lengthOld == 2 && lengthNew == 2) {
        final oldBars = barFrom.toList()..sort();
        final newBars = barTo.toList()..sort();
        _transition(result, progress, oldBars[0], newBars[0]);
        _transition(result, progress, oldBars[1], newBars[1]);
      } else if (lengthOld == 0 && lengthNew == 2) {
        final bars = barTo.toList()..sort();
        _transition(result, progress, _barFrom(bars[0]), bars[0]);
        _transition(result, progress, _barFrom(bars[1]), bars[1]);
      } else if (lengthOld == 2 && lengthNew == 0) {
        final bars = barFrom.toList()..sort();
        _transition(result, progress, bars[0], _barFrom(bars[0]));
        _transition(result, progress, bars[1], _barFrom(bars[1]));
      }
    }
    return result;
  }

  static Bar _barFrom(Bar fromBar, {double startY, double endY}) {
    final barCenter = (fromBar.startY + fromBar.endY) / 2;
    return fromBar.copy(
      startY: startY ?? barCenter,
      endY: endY ?? barCenter,
    );
  }

  /// Create transition from bar [from] to bar [to] based on [progress]
  static void _transition(List<Bar> result, double progress, Bar from, Bar to) {
    double top;
    if (from.startY < to.startY) {
      top = to.startY - (to.startY - from.startY) * (1 - progress);
    } else {
      top = from.startY - (from.startY - to.startY) * progress;
    }
    double bottom;
    if (from.endY < to.endY) {
      bottom = from.endY + (to.endY - from.endY) * progress;
    } else {
      bottom = from.endY - (from.endY - to.endY) * progress;
    }
    result.add(Bar(from.index, startY: top, endY: bottom));
  }

  static const List<List<Bar>> _data = [
    [
      // digit_0
      Bar(0, startY: 0.0000000, endY: 0.2187500),
      Bar(0, startY: 0.7812500, endY: 1.0000000),
      Bar(1, startY: 0.0000000, endY: 0.1171875),
      Bar(1, startY: 0.3906250, endY: 0.6250000),
      Bar(1, startY: 0.8828125, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.0781250),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(2, startY: 0.2968750, endY: 0.7187500),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.2968750, endY: 0.7187500),
      Bar(4, startY: 0.0000000, endY: 0.1171875),
      Bar(4, startY: 0.8828125, endY: 1.0000000),
      Bar(4, startY: 0.3828125, endY: 0.6171875),
      Bar(5, startY: 0.0000000, endY: 0.2187500),
      Bar(5, startY: 0.7812500, endY: 1.0000000),
    ],
    [
      // digit_1
      Bar(0, startY: 0.0000000, endY: 1.0000000),
      Bar(1, startY: 0.0000000, endY: 0.1953125),
      Bar(1, startY: 0.3984375, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.1484375),
      Bar(2, startY: 0.3750000, endY: 1.0000000),
      Bar(3, startY: 0.0000000, endY: 0.1171875),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(4, startY: 0.0000000, endY: 0.0781250),
      Bar(4, startY: 0.9375000, endY: 1.0000000),
      Bar(5, startY: 0.0000000, endY: 1.0000000),
    ],
    [
      // digit_2
      Bar(0, startY: 0.0000000, endY: 0.1953125),
      Bar(0, startY: 0.3203125, endY: 0.7265625),
      Bar(0, startY: 0.9375000, endY: 1.0000000),
      Bar(1, startY: 0.9375000, endY: 1.0000000),
      Bar(1, startY: 0.3515625, endY: 0.6328125),
      Bar(1, startY: 0.0000000, endY: 0.1171875),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(2, startY: 0.2968750, endY: 0.5703125),
      Bar(2, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.2656250, endY: 0.4296875),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(4, startY: 0.9375000, endY: 1.0000000),
      Bar(4, startY: 0.6015625, endY: 0.7265625),
      Bar(4, startY: 0.0000000, endY: 0.1171875),
      Bar(5, startY: 0.9375000, endY: 1.0000000),
      Bar(5, startY: 0.4687500, endY: 0.7265625),
      Bar(5, startY: 0.0000000, endY: 0.1953125),
    ],
    [
      // digit_3
      Bar(0, startY: 0.2656250, endY: 0.6796875),
      Bar(0, startY: 0.8750000, endY: 1.0000000),
      Bar(0, startY: 0.0000000, endY: 0.1406250),
      Bar(1, startY: 0.9218750, endY: 1.0000000),
      Bar(1, startY: 0.3125000, endY: 0.6796875),
      Bar(1, startY: 0.0000000, endY: 0.0937500),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.0781250),
      Bar(2, startY: 0.5859375, endY: 0.7265625),
      Bar(2, startY: 0.2656250, endY: 0.3906250),
      Bar(3, startY: 0.6328125, endY: 0.7265625),
      Bar(3, startY: 0.2812500, endY: 0.3750000),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(4, startY: 0.9218750, endY: 1.0000000),
      Bar(4, startY: 0.0000000, endY: 0.0937500),
      Bar(5, startY: 0.7812500, endY: 1.0000000),
      Bar(5, startY: 0.0000000, endY: 0.2109375),
      Bar(5, startY: 0.4140625, endY: 0.5156250),
    ],
    [
      // digit_4
      Bar(0, startY: 0.7500000, endY: 1.0000000),
      Bar(0, startY: 0.0000000, endY: 0.4765625),
      Bar(1, startY: 0.7500000, endY: 1.0000000),
      Bar(1, startY: 0.0000000, endY: 0.3750000),
      Bar(2, startY: 0.7500000, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.2421875),
      Bar(2, startY: 0.5234375, endY: 0.5781250),
      Bar(3, startY: 0.4765625, endY: 0.5781250),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.0000000, endY: 0.0937500),
      Bar(4, startY: 0.9375000, endY: 1.0000000),
      Bar(4, startY: 0.0000000, endY: 0.0781250),
      Bar(5, startY: 0.0000000, endY: 0.5312500),
      Bar(5, startY: 0.7500000, endY: 1.0000000),
    ],
    [
      // digit_5
      Bar(0, startY: 0.0000000, endY: 0.6171875),
      Bar(0, startY: 0.8515625, endY: 1.0000000),
      Bar(1, startY: 0.0000000, endY: 0.0781250),
      Bar(1, startY: 0.5312500, endY: 0.6796875),
      Bar(1, startY: 0.9062500, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.0781250),
      Bar(2, startY: 0.2812500, endY: 0.3515625),
      Bar(2, startY: 0.5312500, endY: 0.7500000),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.2812500, endY: 0.3515625),
      Bar(3, startY: 0.5312500, endY: 0.7500000),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(4, startY: 0.0000000, endY: 0.0781250),
      Bar(4, startY: 0.2812500, endY: 0.3750000),
      Bar(4, startY: 0.6015625, endY: 0.6718750),
      Bar(4, startY: 0.9062500, endY: 1.0000000),
      Bar(5, startY: 0.0000000, endY: 0.0781250),
      Bar(5, startY: 0.2812500, endY: 0.4296875),
      Bar(5, startY: 0.8593750, endY: 1.0000000),
    ],
    [
      // digit_6
      Bar(0, startY: 0.7734375, endY: 1.0000000),
      Bar(0, startY: 0.0000000, endY: 0.2343750),
      Bar(1, startY: 0.0000000, endY: 0.1171875),
      Bar(1, startY: 0.9062500, endY: 1.0000000),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.0937500),
      Bar(2, startY: 0.3125000, endY: 0.3828125),
      Bar(2, startY: 0.5390625, endY: 0.6953125),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.2500000, endY: 0.3515625),
      Bar(3, startY: 0.5390625, endY: 0.7265625),
      Bar(4, startY: 0.9062500, endY: 1.0000000),
      Bar(4, startY: 0.0000000, endY: 0.0937500),
      Bar(4, startY: 0.2656250, endY: 0.3984375),
      Bar(5, startY: 0.8125000, endY: 1.0000000),
      Bar(5, startY: 0.0000000, endY: 0.1484375),
      Bar(5, startY: 0.2968750, endY: 0.4453125),
    ],
    [
      // digit_7
      Bar(0, startY: 0.0000000, endY: 0.0781250),
      Bar(0, startY: 0.3125000, endY: 1.0000000),
      Bar(1, startY: 0.0000000, endY: 0.0781250),
      Bar(1, startY: 0.3125000, endY: 0.6328125),
      Bar(1, startY: 0.9375000, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.0781250),
      Bar(2, startY: 0.3125000, endY: 0.5156250),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.7890625, endY: 1.0000000),
      Bar(4, startY: 0.5703125, endY: 1.0000000),
      Bar(4, startY: 0.0000000, endY: 0.0781250),
      Bar(5, startY: 0.0000000, endY: 0.0781250),
      Bar(5, startY: 0.2968750, endY: 1.0000000),
    ],
    [
      // digit_8
      Bar(0, startY: 0.0000000, endY: 0.2187500),
      Bar(0, startY: 0.8359375, endY: 1.0000000),
      Bar(0, startY: 0.3828125, endY: 0.5703125),
      Bar(1, startY: 0.0000000, endY: 0.1171875),
      Bar(1, startY: 0.8828125, endY: 1.0000000),
      Bar(2, startY: 0.0000000, endY: 0.0781250),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(2, startY: 0.2734375, endY: 0.3593750),
      Bar(2, startY: 0.6171875, endY: 0.7187500),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.2734375, endY: 0.3593750),
      Bar(3, startY: 0.6171875, endY: 0.7187500),
      Bar(4, startY: 0.0000000, endY: 0.1171875),
      Bar(4, startY: 0.8828125, endY: 1.0000000),
      Bar(5, startY: 0.0000000, endY: 0.2187500),
      Bar(5, startY: 0.8359375, endY: 1.0000000),
      Bar(5, startY: 0.3828125, endY: 0.5703125),
    ],
    [
      // digit_9
      Bar(0, startY: 0.0000000, endY: 0.2187500),
      Bar(0, startY: 0.8437500, endY: 1.0000000),
      Bar(0, startY: 0.5390625, endY: 0.7187500),
      Bar(1, startY: 0.0000000, endY: 0.1171875),
      Bar(1, startY: 0.9062500, endY: 1.0000000),
      Bar(1, startY: 0.6328125, endY: 0.7421875),
      Bar(2, startY: 0.0000000, endY: 0.0781250),
      Bar(2, startY: 0.9375000, endY: 1.0000000),
      Bar(2, startY: 0.6640625, endY: 0.7734375),
      Bar(2, startY: 0.2968750, endY: 0.4687500),
      Bar(3, startY: 0.0000000, endY: 0.0781250),
      Bar(3, startY: 0.9375000, endY: 1.0000000),
      Bar(3, startY: 0.6562500, endY: 0.7656250),
      Bar(3, startY: 0.2968750, endY: 0.4687500),
      Bar(4, startY: 0.0000000, endY: 0.1171875),
      Bar(4, startY: 0.9062500, endY: 1.0000000),
      Bar(5, startY: 0.0000000, endY: 0.2500000),
      Bar(5, startY: 0.7500000, endY: 1.0000000),
    ],
    [
      // colon
      Bar(0, startY: 0.0000000, endY: 0.3000000),
      Bar(0, startY: 0.4000000, endY: 0.6000000),
      Bar(0, startY: 0.7000000, endY: 1.0000000),
    ],
  ];
}

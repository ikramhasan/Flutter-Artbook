import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeumorphicClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnalogClock();
  }
}

final radiansPerTick = pi / 180 * (360 / 60);
final radiansPerHour = pi / 180 * (360 / 12);

class AnalogClock extends StatefulWidget {
  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  bool isDark = true;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    // Set the initial values.
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Neumorphic Clock',
          style: GoogleFonts.quicksand(),),
        centerTitle: true,
      ),
      body: AnimatedTheme(
        data: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            // Hour & Minute hand.
            primaryColor: isDark ? Colors.grey[400] : Colors.grey[800],
            // Second hand.
            accentColor: Colors.red[800],
            // Tick color
            cursorColor: Color(0xFF2D2F41),
            // Shadow color
            canvasColor: isDark ? Color(0xFF2D2F41) : Colors.grey[500],
            // Inner shadow color
            dividerColor: isDark ? Color(0xFF2D2F41) : Colors.grey[400],
            // Inner Highlight Color
            highlightColor: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.7),
            backgroundColor: isDark ? Color(0xFF2D2F41) : Colors.grey[300],
            textTheme: Theme.of(context).textTheme,
            // switch theme
            toggleableActiveColor: Colors.grey[500],
            // icon colors
            iconTheme: IconThemeData(color: Colors.grey[600])),
        child: Builder(builder: (context) {
          return Container(
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final unit = constraints.biggest.height / 25;

                          return ClockData(
                            time: _now,
                            unit: unit,
                            child: Container(
                              padding: EdgeInsets.all(2 * unit),
                              color: Theme.of(context).backgroundColor,
                              child: Stack(
                                children: [
                                  OuterShadows(),
                                  InnerShadows(),
                                  ClockTicks(),
                                  HourHandShadow(),
                                  MinuteHandShadow(),
                                  SecondHandShadow(),
                                  HourHand(),
                                  MinuteHand(),
                                  SecondHand(),
                                  SecondHandCircle(),
                                  ClockPin(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.wb_sunny,
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (v) => setState(() => isDark = v),
                        ),
                        Icon(
                          Icons.brightness_3,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ClockData extends InheritedWidget {
  final DateTime time;
  final double unit;
  @override
  final Widget child;

  ClockData({
    @required this.time,
    @required this.unit,
    @required this.child,
  });

  @override
  bool updateShouldNotify(ClockData oldWidget) =>
      oldWidget.time != time && oldWidget.unit != unit;

  static ClockData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ClockData>();
}

abstract class Hand extends StatelessWidget {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const Hand({
    @required this.color,
    @required this.size,
    @required this.angleRadians,
  })  : assert(color != null),
        assert(size != null),
        assert(angleRadians != null);

  final Color color;
  final double size;
  final double angleRadians;
}

class ContainerHand extends Hand {
  const ContainerHand({
    @required Color color,
    @required double size,
    @required double angleRadians,
    this.child,
  })  : assert(size != null),
        assert(angleRadians != null),
        super(
          color: color,
          size: size,
          angleRadians: angleRadians,
        );

  /// The child widget used as the clock hand and rotated by [angleRadians].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: Transform.rotate(
          angle: angleRadians,
          alignment: Alignment.center,
          child: Transform.scale(
            scale: size,
            alignment: Alignment.center,
            child: Container(
              color: color,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedContainerHand extends StatelessWidget {
  const AnimatedContainerHand({
    Key key,
    @required int now,
    @required Widget child,
    @required double size,
  })  : _now = now,
        _child = child,
        _size = size,
        super(key: key);

  final int _now;
  final Widget _child;
  final double _size;

  @override
  Widget build(BuildContext context) {
    if (_now == 0) {
      return TweenAnimationBuilder<double>(
        key: ValueKey('special_case_when_overflowing'),
        duration: Duration(milliseconds: 300),
        tween: Tween<double>(
          begin: value(_now - 1),
          end: value(_now),
        ),
        curve: Curves.easeInQuint,
        builder: (context, anim, child) {
          return ContainerHand(
            color: Colors.transparent,
            size: _size,
            angleRadians: anim,
            child: child,
          );
        },
        child: _child,
      );
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey('normal_case'),
      duration: Duration(milliseconds: 300),
      tween: Tween<double>(
        begin: value(_now - 1),
        end: value(_now),
      ),
      curve: Curves.easeInQuint,
      builder: (context, anim, child) {
        return ContainerHand(
          color: Colors.transparent,
          size: _size,
          angleRadians: anim,
          child: child,
        );
      },
      child: _child,
    );
  }

  double value(int second) {
    return second * radiansPerTick;
  }
}

class OuterShadows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).highlightColor,
            offset: Offset(-unit / 2, -unit / 2),
            blurRadius: 1.5 * unit,
          ),
          BoxShadow(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            offset: Offset(unit / 2, unit / 2),
            blurRadius: 1.5 * unit,
          ),
        ],
      ),
    );
  }
}

class InnerShadows extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    return Padding(
      padding: EdgeInsets.all(1.5 * unit),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              offset: Offset(-unit / 2, -unit / 2),
              blurRadius: 0.5 * unit,
            ),
            BoxShadow(
              color: Theme.of(context).highlightColor,
              offset: Offset(unit / 2, unit / 2),
              blurRadius: 0.5 * unit,
            ),
          ],
        ),
      ),
    );
  }
}

class ClockTicks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit * 0.8;
    return Stack(
      children: <Widget>[
        for (var i = 0; i < 12; i++)
          Center(
            child: Transform.rotate(
              // convert degrees to radians
              angle: pi / 180 * 360 / 12 * i,
              child: Transform.translate(
                offset: Offset(0, i % 3 == 0 ? -9.7 * unit : -10.2 * unit),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  height: i % 3 == 0 ? 3.0 * unit : 2.0 * unit,
                  width: i % 3 == 0 ? 0.3 * unit : 0.2 * unit,
                ),
              ),
            ),
          )
      ],
    );
  }
}

class HourHandShadow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    final time = ClockData.of(context).time;
    return Transform.translate(
      offset: Offset(unit / 4, unit / 5),
      child: Padding(
        padding: EdgeInsets.all(2 * unit),
        child: ContainerHand(
          color: Colors.transparent,
          size: 0.5,
          angleRadians:
              time.hour * radiansPerHour + (time.minute / 60) * radiansPerHour,
          child: Transform.translate(
            offset: Offset(0.0, -3 * unit),
            child: Container(
              width: 1.5 * unit,
              height: 7 * unit,
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).canvasColor,
                    blurRadius: unit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MinuteHandShadow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    return Transform.translate(
      offset: Offset(unit / 3, unit / 3),
      child: Padding(
        padding: EdgeInsets.all(2 * unit),
        child: AnimatedContainerHand(
          size: 0.5,
          now: ClockData.of(context).time.minute,
          child: Transform.translate(
            offset: Offset(0.0, -8 * unit),
            child: Container(
              width: unit / 2,
              height: unit * 15,
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).canvasColor,
                    blurRadius: unit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondHandShadow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    return Transform.translate(
      offset: Offset(unit / 2, unit / 1.9),
      child: AnimatedContainerHand(
        now: ClockData.of(context).time.second,
        size: 0.6,
        child: Transform.translate(
          offset: Offset(0.0, -4 * unit),
          child: Container(
            width: unit / 3,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).canvasColor,
                  blurRadius: unit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HourHand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    final time = ClockData.of(context).time;
    return Padding(
      padding: EdgeInsets.all(2 * unit),
      child: ContainerHand(
        color: Colors.transparent,
        size: 0.5,
        angleRadians:
            time.hour * radiansPerHour + (time.minute / 60) * radiansPerHour,
        child: Transform.translate(
          offset: Offset(0.0, -3 * unit),
          child: Container(
            width: 1.5 * unit,
            height: 7 * unit,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class MinuteHand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    return Padding(
      padding: EdgeInsets.all(2 * unit),
      child: AnimatedContainerHand(
        size: 0.5,
        now: ClockData.of(context).time.minute,
        child: Transform.translate(
          offset: Offset(0.0, -8 * unit),
          child: Container(
            width: unit / 2,
            height: unit * 15,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class SecondHand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final second = ClockData.of(context).time.second;
    final unit = ClockData.of(context).unit;
    return AnimatedContainerHand(
      now: second,
      size: 0.6,
      child: Transform.translate(
        offset: Offset(0.0, -4 * unit),
        child: Container(
          width: unit / 2,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

class SecondHandCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unit = ClockData.of(context).unit;
    return AnimatedContainerHand(
      now: ClockData.of(context).time.second,
      size: 0.6,
      child: Transform.translate(
        offset: Offset(0.0, 4 * unit),
        child: Container(
          width: 2 * unit,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

class ClockPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 0.8 * ClockData.of(context).unit,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}

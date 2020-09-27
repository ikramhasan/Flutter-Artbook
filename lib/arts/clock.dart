import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Clock',
          style: GoogleFonts.quicksand(),),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        color: Color(0xFF2D2F41),
        child: Container(
          height: 300,
          width: 300,
          // A CustomPainter paints from a 90 degree angle.
          // We need to rotate the whole canvas to adjust the orientation
          child: Transform.rotate(
            angle: -pi / 2,
            child: CustomPaint(
              painter: ClockPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  var dateTime = DateTime.now();

  @override
  void paint(Canvas canvas, Size size) {
    /*
    Custom Painter draws from the top left corner of the screen.
    We want to draw from the center of the screen. So we'll make a 
    variable that hold the coordinates of the center position of the screen
    */
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    // The min method will take the lowest value from the given 2 values
    var radius = min(centerX, centerY);
    // The backgroundPaint variable holds the painting properties of the
    // background fill of the clock
    var backgroundPaint = Paint()..color = Color(0xFF444974);

    var outlinePaint = Paint()
      ..color = Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    var centerDotPaint = Paint()..color = Color(0xFFEAECFF);

    var secondHandPaint = Paint()
      ..color = Colors.orange[300]
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    var minuteHandPaint = Paint()
      ..shader = RadialGradient(colors: [Color(0xFF748EF6), Color(0xFF77DDFF)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    var hourHandPaint = Paint()
      ..shader = RadialGradient(colors: [Color(0xFFEA74AB), Color(0xFFC279FB)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;

    // Draw the clock on the screen

    // This draws the background on the screen
    canvas.drawCircle(center, radius - 40, backgroundPaint);
    canvas.drawCircle(center, radius - 40, outlinePaint);

    // An hour hand takes 12 hours to complete a 360 degree rotation
    // So in 1 hour it will travel 30 degrees
    // Also we should update the hour hand position every minute,
    // Fpr every every minute, an hour hand travels 0.5 degrees
    var hourHandX = centerX +
        60 * cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    var hourHandY = centerX +
        60 * sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandPaint);

    // A minute hand takes 60 minutes to complete a 360 degree rotation
    // So in 1 minute it will travel 6 degrees
    var minuteHandX = centerX + 80 * cos((dateTime.minute * 6) * pi / 180);
    var minuteHandY = centerX + 80 * sin((dateTime.minute * 6) * pi / 180);
    canvas.drawLine(center, Offset(minuteHandX, minuteHandY), minuteHandPaint);

    // A second hand takes 60 seconds to complete a 360 degree rotation
    // So in 1 seconds it will travel 6 degrees
    var secondHandX = centerX + 80 * cos((dateTime.second * 6) * pi / 180);
    var secondHandY = centerX + 80 * sin((dateTime.second * 6) * pi / 180);
    canvas.drawLine(center, Offset(secondHandX, secondHandY), secondHandPaint);

    canvas.drawCircle(center, 16, centerDotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

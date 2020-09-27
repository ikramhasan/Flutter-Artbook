import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ClockOfClocks extends StatefulWidget {
  const ClockOfClocks({Key key}) : super(key: key);

  @override
  _ClockOfClocksState createState() => _ClockOfClocksState();
}

class _ClockOfClocksState extends State<ClockOfClocks> {
  final clockState = ClockState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Clock of Clocks'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FittedBox(
            child: SizedBox(
              width: 1024.0,
              height: 540.0,
              child: GridView.count(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                crossAxisCount: 8,
                children: [
                  for (final model in clockState.clockMeshModels)
                    AnalogClock(
                      key: ObjectKey(model),
                      model: model,
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

class AnalogClock extends StatelessWidget {
  const AnalogClock({Key key, @required this.model}) : super(key: key);

  final AnalogClockModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0x20252525), width: 1),
        gradient: const RadialGradient(
          center: Alignment(0.0, 0.1),
          radius: 1,
          colors: [Colors.white, Colors.black],
          stops: [0.43, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: model,
        builder: (BuildContext context, Widget child) {
          return Stack(
            children: [
              if (model.label != null) ClockLabel(label: model.label),
              for (int i = 0; i < model.handAngles.length; i++)
                TweenAnimationBuilder(
                  curve: Curves.elasticOut,
                  duration: const Duration(milliseconds: 3000),
                  tween: Tween<double>(begin: 0, end: model.handAngles[i]),
                  builder: (_, angle, child) {
                    return Transform.rotate(
                      alignment: Alignment.center,
                      angle: angle,
                      child: child,
                    );
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ClockHand(color: model.color),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ClockLabel extends StatelessWidget {
  const ClockLabel({Key key, @required this.label}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w900,
            color: Color(0x50252525),
          ),
        ),
      ),
    );
  }
}

class ClockHand extends StatelessWidget {
  const ClockHand({Key key, @required this.color}) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.55,
      heightFactor: 0.13,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: color,
        ),
      ),
    );
  }
}

class ClockState {
  List<AnalogClockModel> clockMeshModels;
  DateTime _currentTime;
  Timer _timer;
  List<int> digits = <int>[null, null, null, null];

  ClockState() {
    clockMeshModels = List.unmodifiable(List.generate(120, (int index) {
      return AnalogClockModel(angleForArrangement(clockStartState[index]));
    }));
    Future.delayed(Duration(milliseconds: 2000), () {
      _timer?.cancel();
      final south = angleForArrangement(1);
      final north = angleForArrangement(3);
      clockMeshModels[57].notifyUpdate(south, color: redColor);
      clockMeshModels[58].notifyUpdate(north, label: 'm');
      clockMeshModels[59].notifyUpdate(north, label: 'h');
      clockMeshModels[60].notifyUpdate(north, label: 'D');
      clockMeshModels[61].notifyUpdate(north, color: redColor, label: 'M');
      clockMeshModels[62].notifyUpdate(north);
      _updateTime();
    });
  }

  void _updateTime() {
    _currentTime = DateTime.now();
    _timer = Timer(
      Duration(seconds: 1) - Duration(milliseconds: _currentTime.millisecond),
      _updateTime,
    );

    <int, double>{
      58: (_currentTime.second * pi * 2 / 60) - (pi / 2), // minuteHandAngle
      59: (_currentTime.minute * pi * 2 / 60) - (pi / 2), // hourHandAngle
      60: (_currentTime.hour * pi * 2 / 24) - (pi / 2), // dayHandAngle
      61: (_currentTime.day * pi * 2 / 31) - (pi / 2), // monthHandAngle,
    }.forEach((index, newAngle) {
      if (clockMeshModels[index].handAngles[0] != newAngle ||
          clockMeshModels[index].handAngles[1] != newAngle) {
        clockMeshModels[index].notifyUpdate([newAngle, newAngle]);
      }
    });

    final newDigits = <int>[
      (_currentTime.hour / 10).floor(), // First hour digit.
      (_currentTime.hour % 10).floor(), // Second hour digit.
      (_currentTime.minute / 10).floor(), // First minute digit.
      (_currentTime.minute % 10).floor(), // Second minute digit.
    ];
    for (var index = 0; index < newDigits.length; index++) {
      final newDigit = newDigits[index];
      if (digits[index] != newDigit) {
        digits[index] = newDigit;
        const digitOffsets = [8, 32, 64, 88];
        for (var i = 0; i < 24; i++) {
          final clock = clockMeshModels[digitOffsets[index] + i];
          final arrangement = clockDigitArrangements[newDigit][i];
          Color color;
          if (arrangement == 34) {
            color = greyColor;
          } else if (index == 0 && arrangement < 34) {
            color = redColor;
          } else {
            color = Colors.black;
          }
          clock.notifyUpdate(angleForArrangement(arrangement), color: color);
        }
      }
    }
  }
}

class AnalogClockModel extends ChangeNotifier {
  AnalogClockModel(this.handAngles);

  List<double> handAngles;
  Color color = Colors.black;
  String label;

  void notifyUpdate(List<double> angles, {Color color, String label}) {
    if (handAngles[0] != angles[0] ||
        handAngles[1] != angles[1] ||
        color != null ||
        label != null) {
      handAngles = angles;
      this.color = color ?? this.color;
      this.label = label ?? this.label;
      notifyListeners();
    }
  }
}

List<List<double>> anglesForDigit(List<int> arrangements) {
  return arrangements.map(angleForArrangement).toList();
}

List<double> angleForArrangement(int arrangement) {
  return [
    _anglesForDirection[_directionsForArrangement[arrangement * 2 + 0]],
    _anglesForDirection[_directionsForArrangement[arrangement * 2 + 1]],
  ];
}

const redColor = Color(0xFFFE1212);
const greyColor = Color(0x507C7C7C);

const _anglesForDirection = <double>[
  0.0,
  pi / 4,
  pi / 2,
  3 * pi / 4,
  pi,
  5 * pi / 4,
  3 * pi / 2,
  7 * pi / 4
];

final List<int> _directionsForArrangement = [
  [0, 0, 2, 2, 4, 4, 6, 6, 5, 5, 7, 7, 3, 3, 1, 1, 6, 4],
  [6, 0, 2, 4, 2, 0, 6, 2, 4, 0, 5, 1, 3, 7, 5, 7, 3, 1],
  [0, 1, 0, 3, 0, 7, 0, 5, 2, 1, 2, 3, 2, 7, 2, 5, 4, 1],
  [4, 3, 4, 7, 4, 5, 6, 1, 6, 3, 6, 7, 6, 5, 4, 4, 4, 0],
].expand((el) => el).toList();

final clockStartState = [
  [11, 12, 12, 12, 12, 12, 12, 9, 13, 11, 12, 12, 12, 12, 9, 13, 13, 13],
  [11, 12, 12, 9, 13, 13, 13, 13, 13, 11, 9, 13, 13, 13, 13, 13, 13, 13],
  [13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13],
  [13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13],
  [13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13],
  [13, 10, 8, 13, 13, 13, 13, 13, 10, 12, 12, 8, 13, 13, 13, 10, 12, 12],
  [12, 12, 8, 13, 10, 12, 12, 12, 12, 12, 12, 8],
].expand((el) => el).toList();

final clockDigitArrangements = <List<int>>[
  [
    [35, 11, 12, 12, 12, 12, 9, 35, 35, 13, 1, 12],
    [12, 3, 13, 35, 35, 10, 12, 12, 12, 12, 8, 35],
  ].expand((el) => el).toList(), // 0
  [
    [35, 34, 34, 20, 34, 34, 34, 35, 35, 34, 15, 10],
    [12, 12, 9, 35, 35, 23, 12, 12, 12, 12, 8, 35],
  ].expand((el) => el).toList(), // 1
  [
    [35, 11, 9, 11, 12, 12, 9, 35, 35, 13, 10, 8],
    [11, 9, 13, 35, 35, 10, 12, 12, 8, 10, 8, 35],
  ].expand((el) => el).toList(), // 2,
  [
    [35, 11, 9, 11, 9, 11, 9, 35, 35, 13, 10, 8],
    [10, 8, 13, 35, 35, 10, 12, 12, 12, 12, 8, 35],
  ].expand((el) => el).toList(), // 3
  [
    [35, 11, 12, 12, 9, 34, 34, 35, 35, 10, 12, 9],
    [10, 12, 9, 35, 35, 10, 12, 12, 12, 12, 8, 35],
  ].expand((el) => el).toList(), // 4
  [
    [35, 11, 12, 12, 9, 11, 9, 35, 35, 13, 11, 9],
    [10, 8, 13, 35, 35, 10, 8, 10, 12, 12, 8, 35],
  ].expand((el) => el).toList(), // 5
  [
    [35, 11, 12, 12, 12, 12, 9, 35, 35, 13, 11, 12],
    [9, 14, 13, 35, 35, 10, 8, 34, 10, 12, 8, 35],
  ].expand((el) => el).toList(), // 6
  [
    [35, 11, 9, 34, 24, 12, 9, 35, 35, 13, 10, 31],
    [24, 12, 8, 35, 35, 10, 12, 31, 34, 34, 34, 35],
  ].expand((el) => el).toList(), // 7
  [
    [35, 11, 12, 30, 24, 12, 9, 35, 35, 13, 1, 17],
    [16, 3, 13, 35, 35, 10, 12, 31, 25, 12, 8, 35],
  ].expand((el) => el).toList(), // 8
  [
    [35, 11, 12, 12, 9, 11, 9, 35, 35, 13, 1, 3],
    [10, 8, 13, 35, 35, 10, 12, 12, 12, 12, 8, 35],
  ].expand((el) => el).toList(), // 9
];

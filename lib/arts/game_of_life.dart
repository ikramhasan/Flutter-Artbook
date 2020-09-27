//Made with dartpad.dartlang.org <3
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color cellColor = Color(0xFF444974);
final Color bgColor = Color(0xFF2D2F41);
final TargetPlatform platform = TargetPlatform.android;

List<List<bool>> cells;
final width = 900.0, height = 900.0;
final xRes = 50, yRes = 50;
double cWidth, cHeight;
bool paused = false, fillMode = true;

class GOLPainter extends CustomPainter {
  List<List<bool>> hiddenMat1 = new List<List<bool>>(xRes);
  List<List<bool>> hiddenMat2 = new List<List<bool>>(xRes);

  GOLPainter(double width, double height) {
    cWidth = width / xRes;
    cHeight = height / yRes;
    cells = hiddenMat1;

    for (var i = 0; i < xRes; i++) {
      hiddenMat1[i] = new List<bool>(yRes);
      hiddenMat2[i] = new List<bool>(yRes);
      for (var j = 0; j < yRes; j++) hiddenMat1[i][j] = false;
    }
  }

  void update() {
    if (paused) return;
    List<List<bool>> next = (cells == hiddenMat1 ? hiddenMat2 : hiddenMat1);
    for (var i = 0; i < xRes; i++)
      for (var j = 0; j < yRes; j++) {
        int nCount = countNeighbours(i, j);
        next[i][j] = !cells[i][j] && nCount == 3 ||
            cells[i][j] && nCount >= 2 && nCount <= 3;
      }
    cells = next;
  }

  int countNeighbours(int x, int y) {
    int count = 0;
    for (var i = x - 1; i <= x + 1; i++)
      for (var j = y - 1; j <= y + 1; j++) {
        if (cells[(i + xRes) % xRes][(j + yRes) % yRes]) count++;
      }
    count -= (cells[x][y] ? 1 : 0);
    return count;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset(0, 0) & Size(cWidth * xRes, cHeight * yRes),
        Paint()..color = bgColor);
    for (var i = 0; i < xRes; i++)
      for (var j = 0; j < yRes; j++) {
        if (cells[i][j]) drawCell(canvas, i * cWidth, j * cHeight, cells[i][j]);
      }
  }

  @override
  bool shouldRepaint(GOLPainter oldDelegate) {
    return true;
  }

  void drawCell(Canvas canvas, num x, num y, bool cellState) {
    canvas.drawRect(
        Offset(x, y) & Size(cWidth, cHeight), Paint()..color = cellColor);
  }
}

class GameOfLife extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GameOfLifeState();
  }
}

class _GameOfLifeState extends State<GameOfLife> {
  IconData icon = Icons.pause;
  Timer timer;
  GOLPainter painter = GOLPainter(width, height);

  @override
  void initState() {
    timer = new Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {
        painter.update();
      });
    });
    super.initState();
  }

  void _pointerClick(PointerEvent e) {
    fillMode =
        !cells[e.localPosition.dx ~/ cWidth][e.localPosition.dy ~/ cHeight];
    _pointerDraw(e);
  }

  void _pointerDraw(PointerEvent e) {
    cells[e.localPosition.dx ~/ cWidth][e.localPosition.dy ~/ cHeight] =
        fillMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game of Life",
          style: GoogleFonts.quicksand(),),
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Listener(
                  onPointerMove: _pointerDraw,
                  onPointerDown: _pointerClick,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: CustomPaint(
                      key: ValueKey(timer.tick),
                      painter: painter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: new Icon(icon, size: 25.0),
        onPressed: () {
          paused = !paused;
          icon = icon == Icons.pause ? Icons.play_arrow : Icons.pause;
        },
      ),
    );
  }
}

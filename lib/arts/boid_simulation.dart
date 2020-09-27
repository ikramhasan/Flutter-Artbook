/// Boids algorithm ported from JS to Dart by Dominik Roszkowski
/// Original version by Ben Eater licensesd under MIT
/// Available https://github.com/beneater/boids
///
/// Check out the Smarter Every Day video about
/// this simulation https://www.youtube.com/watch?v=4LWmRuB-uNU
///
/// Find me on Twitter https://twitter.com/OrestesGaolin
/// And my website https://roszkowski.dev/
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';

const double kSize = 150.0;

class BoidSim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boids algorithm demonstration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.dark(),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  BoidSimulation simulation;

  @override
  void initState() {
    super.initState();
    simulation = BoidSimulation(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2F41),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Color Test'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AboutDialog(
                  children: [
                    SelectableText(
                        'This simulation is a Dart port of Boids algorithm demonstration '
                        'created by Ben Eater. '),
                    Container(),
                    SelectableText(
                        'You can see original source on https://github.com/beneater/boids'),
                    Center(
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.open_in_new,
                          color: Colors.black45,
                        ),
                        label: Text(
                          'Follow me on Twitter',
                          style: TextStyle(color: Colors.black54),
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
                painter: BoidPainter(simulation.boids),
                child: Container(
                  height: MediaQuery.of(context).size.shortestSide,
                  width: MediaQuery.of(context).size.shortestSide,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    width: 200,
                    child: Column(
                      children: [
                        Text(
                          'Speed',
                          style: TextStyle(color: Colors.white),
                        ),
                        Slider(
                          value: simulation?.speedLimit,
                          min: 0.0,
                          max: 20.0,
                          onChanged: (value) {
                            simulation.speedLimit = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 200,
                    child: Column(
                      children: [
                        Text(
                          'Visual Range',
                          style: TextStyle(color: Colors.white),
                        ),
                        Slider(
                          value: simulation?.visualRange,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (value) {
                            simulation.visualRange = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 200,
                    child: Column(
                      children: [
                        Text(
                          'Boids number',
                          style: TextStyle(color: Colors.white),
                        ),
                        Slider(
                          value: simulation?.numBoids?.toDouble(),
                          min: 0,
                          max: 200,
                          onChanged: (value) {
                            simulation.setBoidsNumber(value.toInt());
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 200,
                    child: Column(
                      children: [
                        Text(
                          'Turn factor',
                          style: TextStyle(color: Colors.white),
                        ),
                        Slider(
                          value: simulation?.turnFactor,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            simulation.turnFactor = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoidPainter extends CustomPainter {
  final List<Boid> boids;
  BoidPainter(this.boids);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / kSize / 2;
    canvas.translate(size.width / 4, size.height / 4);
    canvas.scale(scale);
    canvas.save();
    for (var boid in boids) {
      canvas.drawCircle(boid.position, 1.0, Paint()..color = Colors.white);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Boid {
  double x;
  double y;
  double dx;
  double dy;

  Offset get position => Offset(x, y);
  Offset get velocity => Offset(dx, dy);

  List<Offset> history = [];

  Boid(this.x, this.y, this.dx, this.dy);

  bool operator ==(dynamic other) {
    if (other is Boid) {
      return other.x == this.x &&
          other.y == this.y &&
          other.dx == this.dx &&
          other.dy == this.dy;
    } else
      return false;
  }

  @override
  int get hashCode => (x * y * dx * dy).toInt();
}

class BoidSimulation extends ChangeNotifier {
  double speedLimit = 5.0;
  double visualRange = 40.0;
  int numBoids = 100;
  double turnFactor = 0.2;

  final double width = kSize;
  final double height = kSize;

  final List<Boid> boids = [];
  final TickerProvider vsync;
  Ticker _ticker;
  double _time = 0.0;

  BoidSimulation(this.vsync) {
    initBoids();
    _ticker = vsync.createTicker(_onEachTick)..start();
  }

  void _onEachTick(Duration deltaTime) {
    final lastFrameTime = deltaTime.inMilliseconds.toDouble() / 1000.0;
    _time += lastFrameTime;

    for (var boid in boids) {
      // Update the velocities according to each rule
      _flyTowardsCenter(boid);
      _avoidOthers(boid);
      _matchVelocity(boid);
      limitSpeed(boid);
      _keepWithinBounds(boid);

      // Update the position based on the current velocity
      boid.x += boid.dx;
      boid.y += boid.dy;
      boid.history.add(boid.position);
      boid.history = boid.history.take(50).toList();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void initBoids([int init = 0]) {
    for (var i = init; i < numBoids; i++) {
      final x = math.Random().nextDouble() * width;
      final y = math.Random().nextDouble() * height;
      final dx = math.Random().nextDouble() * 10 - 5;
      final dy = math.Random().nextDouble() * 10 - 5;
      boids.add(Boid(x, y, dx, dy));
    }
  }

  void setBoidsNumber(int value) {
    numBoids = value;
    if (numBoids < boids.length) {
      boids.removeRange(numBoids, boids.length);
    } else {
      initBoids(boids.length);
    }
  }

  double _distance(Boid boid1, Boid boid2) {
    return math.sqrt(
      (boid1.x - boid2.x) * (boid1.x - boid2.x) +
          (boid1.y - boid2.y) * (boid1.y - boid2.y),
    );
  }

  /// Constrain a boid to within the window. If it gets too close to an edge,
  /// nudge it back in and reverse its direction.
  void _keepWithinBounds(Boid boid) {
    const margin = 50;

    if (boid.x < width + margin) {
      boid.dx += turnFactor;
    }
    if (boid.x > -margin) {
      boid.dx -= turnFactor;
    }
    if (boid.y < height + margin) {
      boid.dy += turnFactor;
    }
    if (boid.y > -margin) {
      boid.dy -= turnFactor;
    }
  }

  /// Find the center of mass of the other boids and adjust velocity slightly to
  /// point towards the center of mass.
  void _flyTowardsCenter(Boid boid) {
    const centeringFactor = 0.005; // adjust velocity by this %

    var centerX = 0.0;
    var centerY = 0.0;
    var numNeighbors = 0.0;

    for (var otherBoid in boids) {
      if (_distance(boid, otherBoid) < visualRange) {
        centerX += otherBoid.x;
        centerY += otherBoid.y;
        numNeighbors += 1;
      }
    }

    if (numNeighbors > 0.0) {
      centerX = centerX / numNeighbors;
      centerY = centerY / numNeighbors;

      boid.dx += (centerX - boid.x) * centeringFactor;
      boid.dy += (centerY - boid.y) * centeringFactor;
    }
  }

  /// Move away from other boids that are too close to avoid colliding
  void _avoidOthers(Boid boid) {
    const minDistance = 10; // The distance to stay away from other boids
    const avoidFactor = 0.01; // Adjust velocity by this %
    var moveX = 0.0;
    var moveY = 0.0;
    for (var otherBoid in boids) {
      if (otherBoid != boid) {
        if (_distance(boid, otherBoid) < minDistance) {
          moveX += boid.x - otherBoid.x;
          moveY += boid.y - otherBoid.y;
        }
      }
    }

    boid.dx += moveX * avoidFactor;
    boid.dy += moveY * avoidFactor;
  }

  /// Find the average velocity (speed and direction) of the other boids and
  /// adjust velocity slightly to match.
  void _matchVelocity(Boid boid) {
    const matchingFactor = 0.05; // Adjust by this % of average velocity

    var avgDX = 0.0;
    var avgDY = 0.0;
    var numNeighbors = 0.0;

    for (var otherBoid in boids) {
      if (_distance(boid, otherBoid) < visualRange) {
        avgDX += otherBoid.dx;
        avgDY += otherBoid.dy;
        numNeighbors += 1;
      }
    }

    if (numNeighbors > 0.0) {
      avgDX = avgDX / numNeighbors;
      avgDY = avgDY / numNeighbors;

      boid.dx += (avgDX - boid.dx) * matchingFactor;
      boid.dy += (avgDY - boid.dy) * matchingFactor;
    }
  }

  /// Speed will naturally vary in flocking behavior, but real animals can't go
  /// arbitrarily fast.
  void limitSpeed(boid) {
    final speed = math.sqrt(boid.dx * boid.dx + boid.dy * boid.dy);
    if (speed > speedLimit) {
      boid.dx = (boid.dx / speed) * speedLimit;
      boid.dy = (boid.dy / speed) * speedLimit;
    }
  }
}

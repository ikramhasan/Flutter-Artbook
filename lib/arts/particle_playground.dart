import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// https://twitter.com/creativemaybeno/status/1290173415530299392?s=20
/// Based on https://codegolf.tk/a/321.

/// [StatefulWidget] managing the animation for the custom painter.
class ParticlePlayground extends StatefulWidget {
  /// Constructs a `const` [ParticlePlayground].
  const ParticlePlayground();

  @override
  _ParticlePlaygroundState createState() => _ParticlePlaygroundState();
}

class _ParticlePlaygroundState extends State<ParticlePlayground> {
  /// Notifies the animation about the currently elapsed time.
  ValueNotifier<double> _time;

  /// Updates the [_time].
  Timer _timer;

  /// Configurable attributes of the simulation.
  double _particleCount = 700,
      _particleSize = 12,
      _blackHoleRadius = 100,
      _sprayRadius = 23;

  /// Convenience list for the configurable attributes that makes creating
  /// input fields for them easy.
  List<List<Object>> _configurables;

  /// Controller for the [_configurables].
  List<TextEditingController> _inputControllers;

  @override
  void initState() {
    super.initState();

    // Setup time.
    _time = ValueNotifier(0);
    // Setup timer.
    final begin = DateTime.now();
    _timer = Timer.periodic(
      Duration(
        // Update up to 60 times a second.
        microseconds: 1e6 ~/ 60,
      ),
      (_) {
        _time.value = DateTime.now().difference(begin).inMicroseconds / 1e6;
      },
    );

    // Setup configurables.
    _configurables = [
      [
        'Particle count',
        () => _particleCount,
        ($) => _particleCount = $,
      ],
      [
        'Spray radius',
        () => _sprayRadius,
        ($) => _sprayRadius = $,
      ],
      [
        'Particle size',
        () => _particleSize,
        ($) => _particleSize = $,
      ],
      [
        'Black hole radius',
        () => _blackHoleRadius,
        ($) => _blackHoleRadius = $,
      ],
    ];

    _inputControllers = _configurables.map((attribute) {
      return TextEditingController(text: '${(attribute[1] as Function)()}');
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _inputControllers) {
      controller.dispose();
    }

    _timer.cancel();
    _time.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Particle Playground',
          style: GoogleFonts.quicksand(),),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            willChange: true,
            painter: Painter(
              _time,
              particleCount: _particleCount,
              particleSize: _particleSize,
              blackHoleRadius: _blackHoleRadius,
              sprayRadius: _sprayRadius,
            ),
          ),
          // Show text fields that allow configuring some attributes of the
          // animation.
          SizedBox(
            height: 60,
            child: Row(
              children: [
                for (var i = 0; i < _configurables.length; i++)
                  Flexible(
                    child: TextField(
                      controller: _inputControllers[i],
                      onChanged: (text) {
                        final value = int.parse(text);

                        setState(() {
                          (_configurables[i][2] as Function)(value);
                        });
                      },
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: _configurables[i][0] as String,
                        contentPadding: const EdgeInsets.only(
                          left: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Calculates the hypotenuse of a triangle with side lengths [v1] and [v2].
///
/// This means that the square root of the sum of squares of [v1] and [v2] is
/// returned from this function.
double hypot(num v1, num v2) {
  return sqrt(pow(v1, 2) + pow(v2, 2));
}

/// [CustomPainter] that takes care of actually painting the animation.
class Painter extends CustomPainter {
  /// Constructs a [Painter] given an [time].
  Painter(
    this.time, {
    this.particleCount,
    this.blackHoleRadius,
    this.sprayRadius,
    this.particleSize,
  }) : super(repaint: time);

  /// Time that controls how the animation is drawn.
  ///
  /// The value of this animation should be `t` in seconds.
  final ValueListenable<double> time;

  /// The number of particles that fly around and will be created after the
  /// previous particles reach the destination each time.
  final particleCount;

  /// How close the particles need to be to the destination in order to reach it.
  final blackHoleRadius;

  /// How many pixels the particles should be sprayed out around the creation
  /// point initially.
  final sprayRadius;

  /// Size for each particle.
  ///
  /// The width and height of each particle drawn is equal to this size value.
  final particleSize;

  /// Padding controlling the minimum distance any destination for the particles
  /// can be away from any edge of the available space.
  static final _destinationPadding = 124;

  /// Position of the particles.
  double _x, _y;

  /// All information about all particles.
  List<List<double>> _particles;

  /// Creates a fresh bunch of particles that will decay over time (until
  /// they reach the destination).
  void _createParticles(Size size) {
    // Random that will be used to create the particles.
    final random = Random();

    // Start without any particles.
    _particles = [];

    // Create the particles.
    for (var i = 0; i < particleCount; i++) {
      // The angle of this particle.
      // Each particle is distributed in a circle around the creation point.
      // In total, the particles fill up all angles in _particleCount steps.
      final angle = pi * 2 / particleCount * i;

      // Add a particle at the current position and random initial values.
      _particles.add([
        _x,
        _y,
        sin(angle) * sprayRadius * random.nextDouble(),
        cos(angle) * sprayRadius * random.nextDouble(),
        0,
      ]);
    }

    // Select a random destination for the particles in the available space.
    // The destination is padded to avoid particles flying off screen.
    _x = _destinationPadding +
        random.nextDouble() * (size.width - _destinationPadding * 2);
    _y = _destinationPadding +
        random.nextDouble() * (size.height - _destinationPadding * 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Time in seconds.
    final t = time.value;

    // Initialize x and y based on the size.
    if (_x == null) {
      _x = size.width / 2;
      _y = size.height / 2;
    }

    // Create particles initially and when all particles have reached the
    // destination.
    if (_particles?.isEmpty != false) {
      _createParticles(size);
    }

    // Draw background.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color =
            // Dart dark blue with low alpha for streaks.
            const Color.fromARGB(255, 18, 32, 47),
    );

    // Draw all particles and advance them.
    for (final particle in _particles) {
      // Set the distance of this particle to the destination.
      particle[4] = hypot(_x - particle[0], _y - particle[1]);

      // Advance this particle and paint it.

      // Update spread.
      final c = pow(particle[4], 2) / 250;
      particle[2] += (_x - particle[0]) / c;
      particle[3] += (_y - particle[1]) / c;

      // Derive the color from HSL.
      final color = HSLColor.fromAHSL(
        1,
        (t * 4e2 - hypot(particle[2], particle[3]) * 29) % 360,
        .8,
        .85,
      ).toColor();

      // Advance in the x direction.
      particle[2] *= .97;
      particle[0] += particle[2];

      // Advance in the y direction.
      particle[3] *= .97;
      particle[1] += particle[3];

      // Draw the particle.
      canvas.drawOval(
        Rect.fromLTWH(
          particle[0],
          particle[1],
          particleSize,
          particleSize,
        ),
        Paint()..color = color,
      );
    }

    // Remove particles that have reached the destination.
    _particles.removeWhere((particle) {
      return particle[4] < blackHoleRadius;
    });
  }

  @override
  bool shouldRepaint(_) =>
      // Repaints should only be triggered by the time.
      // Whether this is true or false does not matter at all.
      false;
}

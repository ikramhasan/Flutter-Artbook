import 'package:artbook/arts/clock.dart';
import 'package:artbook/arts/algrafx.dart';
import 'package:artbook/arts/animated_circles.dart';
import 'package:artbook/arts/barbar_clock.dart';
import 'package:artbook/arts/clock_of_clocks.dart';
import 'package:artbook/arts/boid_simulation.dart';
import 'package:artbook/arts/color_test.dart';
import 'package:artbook/arts/dancing_phyllotaxis.dart';
import 'package:artbook/arts/double_pendulum_simulation.dart';
import 'package:artbook/arts/game_of_life.dart';
import 'package:artbook/arts/long_shadow_animation.dart';
import 'package:artbook/arts/neumorphic_clock.dart';
import 'package:artbook/arts/particle_playground.dart';
import 'package:artbook/arts/planet_simulator.dart';
import 'package:artbook/arts/sierpinski_triangle.dart';
import 'package:artbook/arts/space.dart';
import 'package:artbook/arts/spinnies.dart';
import 'package:artbook/arts/sunflower.dart';
import 'package:artbook/models/art_object.dart';

final artList = [
  ArtObject(title: 'Modern Clock', object: Clock()),
  ArtObject(title: 'Clock of Clocks', object: ClockOfClocks()),
  ArtObject(title: 'BarBar Clock', object: BarBar()),
  ArtObject(title: 'Dancing Phyllotaxis', object: DancingPhyllotaxis()),
  ArtObject(title: 'Spinnies', object: SpinniesApp()),
  ArtObject(title: 'Color Test', object: ColorTest()),
  ArtObject(title: 'Planet Simulator', object: PlanetSimulator()),
  ArtObject(title: 'Algrafx', object: Algrafx()),
  ArtObject(title: 'Boids Simulation', object: BoidSim()),
  ArtObject(title: 'Sierpinski Triangle', object: Sierpinski()),
  ArtObject(title: 'Animated Cirlces', object: AnimatedCircles()),
  ArtObject(title: 'Space', object: Space()),
  ArtObject(title: 'Game of Life', object: GameOfLife()),
  ArtObject(title: 'Sunflowers', object: Sunflower()),
  ArtObject(title: 'Neumorphic Clock', object: NeumorphicClock()),
  ArtObject(title: 'Particle Playground', object: ParticlePlayground()),
  ArtObject(
      title: 'Double Pendulum Simulation', object: DoublePendulumSimulation()),
  ArtObject(title: 'Long Shadow Animation', object: LongShadowAnimationPage()),
];

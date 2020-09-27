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
  ArtObject(
    title: 'Modern Clock',
    object: Clock(),
    photoUrl: 'assets/minimal-clock.png',
  ),
  ArtObject(
    title: 'Clock of Clocks',
    object: ClockOfClocks(),
    photoUrl: 'assets/clock-of-clocks.png',
  ),
  ArtObject(
    title: 'Bar Clock',
    object: BarBar(),
    photoUrl: 'assets/bar-clock.png',
  ),
  ArtObject(
    title: 'Dancing Phyllotaxis',
    object: DancingPhyllotaxis(),
    photoUrl: 'assets/dancing-phyllotaxis.png',
  ),
  ArtObject(
    title: 'Spinnies',
    object: SpinniesApp(),
    photoUrl: 'assets/spinnies.png',
  ),
  ArtObject(
    title: 'Animated Random Colors',
    object: ColorTest(),
    photoUrl: 'assets/animated-random-colors.png',
  ),
  ArtObject(
    title: 'Planet Simulator',
    object: PlanetSimulator(),
    photoUrl: 'assets/planet-simulator.png',
  ),
  ArtObject(
    title: 'Algrafx',
    object: Algrafx(),
    photoUrl: 'assets/algrafx.png',
  ),
  ArtObject(
    title: 'Boids Simulation',
    object: BoidSim(),
    photoUrl: 'assets/boids-simulation.png',
  ),
  ArtObject(
    title: 'Sierpinski Triangle',
    object: Sierpinski(),
    photoUrl: 'assets/sierpinski-triangle.png',
  ),
  ArtObject(
    title: 'Animated Cirlces',
    object: AnimatedCircles(),
    photoUrl: 'assets/animated-circles.png',
  ),
  ArtObject(
    title: 'Space',
    object: Space(),
    photoUrl: 'assets/space.png',
  ),
  ArtObject(
    title: 'Game of Life',
    object: GameOfLife(),
    photoUrl: 'assets/game-of-life.png',
  ),
  ArtObject(
    title: 'Sunflowers',
    object: Sunflower(),
    photoUrl: 'assets/sunflowers.png',
  ),
  ArtObject(
    title: 'Neumorphic Clock',
    object: NeumorphicClock(),
    photoUrl: 'assets/neumorphic-clock.png',
  ),
  ArtObject(
    title: 'Particle Playground',
    object: ParticlePlayground(),
    photoUrl: 'assets/particle-playground.png',
  ),
  ArtObject(
    title: 'Double Pendulum Simulation',
    object: DoublePendulumSimulation(),
    photoUrl: 'assets/double-pendulum.png',
  ),
  ArtObject(
    title: 'Long Shadow Animation',
    object: LongShadowAnimationPage(),
    photoUrl: 'assets/long-shadows.png',
  ),
];

import 'package:artbook/arts/algrafx.dart';
import 'package:artbook/arts/animated_circles.dart';
import 'package:artbook/arts/boid_simulation.dart';
import 'package:artbook/arts/clock.dart';
import 'package:artbook/arts/color_test.dart';
import 'package:artbook/arts/dancing_phyllotaxis.dart';
import 'package:artbook/arts/planet_simulator.dart';
import 'package:artbook/arts/sierpinski_triangle.dart';
import 'package:artbook/arts/spinnies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text('Flutter Artbook'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                  'Generative Arts',
                  style: TextStyle(
                    color: Color(0xFFEAECFF),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF444974),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(Clock());
              },
              child: ListTile(
                title: Text(
                  'Clock',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(DancingPhyllotaxis());
              },
              child: ListTile(
                title: Text(
                  'Dancing Phyllotaxis',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(SpinniesApp());
              },
              child: ListTile(
                title: Text(
                  'Spinnies',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(ColorTest());
              },
              child: ListTile(
                title: Text(
                  'Color Test',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(PlanetSimulator());
              },
              child: ListTile(
                title: Text(
                  'Planet Simulator',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(Algrafx());
              },
              child: ListTile(
                title: Text(
                  'Algrafx',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(BoidSim());
              },
              child: ListTile(
                title: Text(
                  'Boids Simulation',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(Sierpinski());
              },
              child: ListTile(
                title: Text(
                  'Sierpinski Triangle',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
            InkWell(
              highlightColor: Color(0xFF444974),
              onTap: () {
                Get.to(AnimatedCircles());
              },
              child: ListTile(
                title: Text(
                  'Animated Cirlces',
                  style: TextStyle(color: Color(0xFFEAECFF)),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Color(0xFF2D2F41),
      ),
    );
  }
}

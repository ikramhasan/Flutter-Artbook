import 'package:artbook/arts/clock.dart';
import 'package:artbook/arts/dancing_phyllotaxis.dart';
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

import 'package:artbook/widgets/art_cards.dart';
import 'package:artbook/widgets/my_drawer.dart';
import 'package:flutter/material.dart';

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
      drawer: MyDrawer(),
      body: Container(
        alignment: Alignment.center,
        color: Color(0xFF2D2F41),
        child: Column(
          children: [
            SizedBox(height: 15),
            Text(
              'A Curated List of Generative Art Made With Flutter!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEAECFF),
              ),
            ),
            SizedBox(height: 15),
            ArtCards(),
          ],
        ),
      ),
    );
  }
}

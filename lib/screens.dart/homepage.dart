import 'package:artbook/screens.dart/about.dart';
import 'package:artbook/widgets/art_cards.dart';
import 'package:artbook/widgets/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
          'Flutter Artbook',
          style: GoogleFonts.quicksand(),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                Get.to(About());
              },
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.infoCircle,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Container(
        alignment: Alignment.center,
        color: Color(0xFF2D2F41),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              'A Curated List of Generative Art Made With Flutter!',
              style: GoogleFonts.quicksand(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEAECFF),
              ),
            ),
            SizedBox(height: 30),
            ArtCards(),
          ],
        ),
      ),
    );
  }
}

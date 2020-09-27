import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'homepage.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter ArtBook',
      theme: ThemeData(
        brightness: Brightness.dark,
        canvasColor: Color(0xFF2D2F41),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

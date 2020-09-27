import 'package:artbook/data/data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 60,
            width: double.infinity,
            color: Color(0xFF444974),
            child: Center(
              child: Text(
                'Generative Arts',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEAECFF),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  hoverColor: Color(0xFF444974),
                  selectedTileColor: Color(0xFF444974),
                  title: Text(
                    artList[index].title,
                    style: GoogleFonts.quicksand(
                      color: Color(0xFFEAECFF),
                    ),
                  ),
                  onTap: () => Get.to(artList[index].object),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: artList.length,
            ),
          ),
        ],
      ),
    );
  }
}

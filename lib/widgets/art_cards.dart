import 'package:artbook/arts/game_of_life.dart';
import 'package:artbook/data/data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (screenWidth > 1400)
                ? 4
                : (screenWidth > 980) ? 3 : (screenWidth > 650) ? 2 : 1),
        itemCount: artList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              artList[index].photoUrl == null
                  ? Container()
                  : InkWell(
                      onTap: () => Get.to(artList[index].object),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 300,
                        width: 300,
                        child: Image.asset(
                          artList[index].photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              SizedBox(height: 8),
              Text(
                artList[index].title,
                style: GoogleFonts.quicksand(fontSize: 16),
              ),
            ],
          );
        },
      ),
    );
  }
}

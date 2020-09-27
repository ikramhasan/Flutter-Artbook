import 'package:artbook/arts/game_of_life.dart';
import 'package:artbook/data/data.dart';
import 'package:flutter/material.dart';

class ArtCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
                  : Container(
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
              Text(artList[index].title),
            ],
          );
        },
      ),
    );
  }
}

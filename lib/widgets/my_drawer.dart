import 'package:artbook/data/data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(
            hoverColor: Color(0xFF444974),
            selectedTileColor: Color(0xFF444974),
            title: Text(
              artList[index].title,
              style: TextStyle(
                color: Color(0xFFEAECFF),
              ),
            ),
            onTap: () => Get.to(artList[index].object),
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: artList.length,
      ),
    );
  }
}

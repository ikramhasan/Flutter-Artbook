import 'package:flutter/widgets.dart';

class ArtObject {
  final String title;
  final Object object;
  final String photoUrl;

  ArtObject({
    @required this.title,
    @required this.object,
    this.photoUrl,
  });
}

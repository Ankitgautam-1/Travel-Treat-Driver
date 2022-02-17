import 'dart:io';

import 'package:flutter/cupertino.dart';

class ImageData extends ChangeNotifier {
  File? image;
  File? cab_image;

  void updateimage(File? profile, File? cab) {
    image = profile;
    cab_image = cab;
    notifyListeners();
  }
}

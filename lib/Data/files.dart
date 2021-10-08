import 'dart:io';
import 'package:flutter/foundation.dart';

class Files extends ChangeNotifier {
  File? file1, file2, file3, file4, file5;

  void updatefile(
      File? file1, File? file2, File? file3, File? file4, File? file5) {
    this.file1 = file1;
    this.file2 = file2;
    this.file3 = file3;
    this.file4 = file4;
    this.file5 = file5;

    notifyListeners();
  }
}

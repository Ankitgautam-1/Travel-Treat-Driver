import 'package:flutter/cupertino.dart';

class UserAccount {
  String Username;
  String Email;
  String Ph;
  dynamic Image;
  String Uid;
  String rating;
  String CarModel;
  String CarNumber;
  String CarClass;
  String CarUrl;
  UserAccount(
      {required this.Email,
      required this.Image,
      required this.Ph,
      required this.Uid,
      required this.Username,
      required this.rating,
      required this.CarModel,
      required this.CarNumber,
      required this.CarClass,
      required this.CarUrl});
}

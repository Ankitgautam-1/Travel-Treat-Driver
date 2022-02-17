import 'package:flutter/cupertino.dart';
import 'package:driver/models/userAccount.dart';

class AccountProvider extends ChangeNotifier {
  UserAccount userAccount = UserAccount(
      Email: "",
      Image: "",
      Ph: "",
      Uid: "",
      Username: "",
      CarClass: "",
      CarModel: "",
      CarNumber: "",
      CarUrl: "",
      rating: "");

  void updateuseraccount(UserAccount userAccData) {
    userAccount = userAccData;
    notifyListeners();
  }
}

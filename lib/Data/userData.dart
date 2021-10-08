import 'package:flutter/cupertino.dart';
import 'package:driver/models/userAddress.dart';

class UserData extends ChangeNotifier {
  UserAddress pickuplocation = UserAddress(placeAddres: "", lat: 0, lng: 0);
  void updatepickuplocation(UserAddress pickupAddress) {
    pickuplocation = pickupAddress;
    notifyListeners();
  }
}

import 'package:driver/models/passenger_info.dart';
import 'package:flutter/cupertino.dart';

class PassengerProvider extends ChangeNotifier {
  Passenger passenger = Passenger(
      name: "",
      token: "",
      destination_address: "",
      phone_number: "",
      pickup_address: "",
      profile_url: "");
  void updatePassenger(Passenger passenger) {
    this.passenger = passenger;
    notifyListeners();
  }
}

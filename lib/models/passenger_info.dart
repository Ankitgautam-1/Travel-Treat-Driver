import 'package:flutter/cupertino.dart';

class Passenger{
  String name;
  String token;
  String pickup_address;
  String destination_address;
  String phone_number;
  String profile_url;
  Passenger({required this.name, required this.token,required this.destination_address,required this.phone_number,
      required this.pickup_address,required this.profile_url});
}
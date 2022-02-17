import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const String base_url = "https://trueway-directions2.p.rapidapi.com";

class Msg {
  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Authorization":
        "key=AAAAPRPTcI4:APA91bGhPLuD0PnXQUUjJzD5UT6ZHygYMVGLflvrCduE_mwjitytNpYDa4Vr3vWENwcv4C_L8B6G9LvPO8HDImQ4ZpIXQ8E9bdYUuAPzY-JLSRfg109P7_nV4A1U6gJiPdwnro2V9u73"
  };
//URI - Uniform resource identifier
  Future<void> sendNotification(String token) async {
    Uri url = Uri.parse("https://fcm.googleapis.com/fcm/send");
    dynamic bodydata = jsonEncode(<String, dynamic>{
      "data": {
        "title": "New Text Message",
        "image": "https://firebase.google.com/images/social.png",
        "message": "Hello how are you?"
      },
      "to": token
    });
    print("Url = $url");
    try {
      final response = await http.post(url, headers: _headers, body: bodydata);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.
          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
        } catch (e) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error is :$e");
      return null;
    }
  }

  Future<dynamic> sendCancelRidereq(
    String token,
  ) async {
    Uri url = Uri.parse("https://fcm.googleapis.com/fcm/send");
    dynamic bodydata = jsonEncode(<String, dynamic>{
      "data": {
        "type": "Ride Cancel",
        "image": "https://firebase.google.com/images/social.png",
        "message": "No bro i can't"
      },
      "to": token
    });
    print("Url = $url");
    try {
      final response = await http.post(url, headers: _headers, body: bodydata);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.
          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
        } catch (e) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error is :$e");
      return null;
    }
  }

  Future<void> sendAcceptRidereq(
      String uid,
      String username,
      String phone,
      String usertoken,
      String lat,
      String long,
      String timetoreach,
      String cab_model,
      String cab_number,
      String rating,
      String drivers_token
      ) async {
    Uri url = Uri.parse("https://fcm.googleapis.com/fcm/send");
    dynamic bodydata = jsonEncode(<String, dynamic>{
      "data": {
        "type": "Ride Accept",
        "uid": uid,
        "cab_image":
            "https://ugxqtrototfqtawjhnol.supabase.in/storage/v1/object/public/travel-treat-storage/Drivers/$uid/${uid}_cabimage",
        "username": username,
        "imageurl":
            "https://ugxqtrototfqtawjhnol.supabase.in/storage/v1/object/public/travel-treat-storage/Drivers/$uid/$uid",
        "phone": phone,
        "lat": lat,
        "long": long,
        "time": timetoreach,
        "cab_model": cab_model,
        "cab_number": cab_number,
        "rating": rating,
        "drivers_token":drivers_token,
      },
      "to": usertoken
    });
    print("Url = $url");
    try {
      final response = await http.post(url, headers: _headers, body: bodydata);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.
          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
        } catch (e) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error is :$e");
      return null;
    }
  }
}

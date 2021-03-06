import 'dart:convert';

import 'package:driver/models/Direction_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const String base_url = "https://trueway-directions2.p.rapidapi.com";

class Directions {
  String endpoint;
  String origin;
  String destination;
  BuildContext context;
  Directions(
      {required this.endpoint,
      required this.origin,
      required this.destination,
      required this.context});
  static const Map<String, String> _headers = {
    "x-rapidapi-key": "39742dd90emsh55eddbdd0f149d1p15562ajsn437a00f3158c",
    "x-rapidapi-host": "trueway-directions2.p.rapidapi.com"
  };
//URI - Uniform resource identifier
  Future<List?> getDirections() async {
    Uri url = Uri.parse(base_url +
        "/" +
        endpoint +
        "?origin=" +
        origin +
        "&destination=" +
        destination);

    print("Url = $url ");
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.

          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
          var res = jsonDecode(response.body);
          List cordinates = res["route"]["geometry"]["coordinates"];
          print("cordinates:$cordinates");

          LatLngBounds bounds = LatLngBounds(
              southwest: LatLng(res["route"]["bounds"]["south"],
                  res["route"]["bounds"]["west"]),
              northeast: LatLng(res["route"]["bounds"]["north"],
                  res["route"]["bounds"]["east"]));
          List<LatLng> cordinates_collections = [];
          for (int i = 0; i < cordinates.length; i++) {
            for (int j = 0; j < cordinates[i].length; j = j + 2) {
              print("j=$j ");
              print("data: ${cordinates[i][j]}");
              cordinates_collections
                  .add(LatLng(cordinates[i][j], cordinates[i][j + 1]));
            }
          }
          print("new here:->cordinates_collections:$cordinates_collections");

          int time = res["route"]["duration"];
          print("time $time");
          int distance = res["route"]["distance"];
          print("Time $time and Distance $distance");
          print("time-->$time and distance-->$distance");
          Set<Polyline> _polyline = {
            Polyline(
                width: 3,
                polylineId: PolylineId("1"),
                color: Colors.black,
                jointType: JointType.bevel,
                points: cordinates_collections)
          };
          Provider.of<DirectionsProvider>(context, listen: false)
              .updateDirectionsProvider(
                  cordinates_collections, bounds, time, distance, _polyline);
          print("the Data is here");
          List the_data = [
            cordinates_collections,
            time.toString(),
            distance.toString()
          ];
          print('the Data in getDirections api${the_data}');
          return the_data;
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

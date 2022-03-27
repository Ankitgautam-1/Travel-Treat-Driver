import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsProvider extends ChangeNotifier {
  List<LatLng>? cordinates_collections = [];
  // ignore: avoid_init_to_null
  LatLngBounds? bounds = null;
  double? time;
  double? distance;
  Set<Polyline>? polylines = {};
  updateDirectionsProvider(List<LatLng>? cordinates, LatLngBounds? bound,
      int? time, int? distance, Set<Polyline> _polylines) {
    print("TIME-->$time and Distance $distance");
    if (time != null && distance != null) {
      cordinates_collections = cordinates;
      this.bounds = bound;
      this.time = time / 60;
      this.distance = distance / 1000;
      this.polylines = _polylines;
    } else {
      this.bounds = null;
      this.time = null;
      this.distance = null;
      this.cordinates_collections = [];
      this.polylines = {};
    }

    notifyListeners();
  }
}

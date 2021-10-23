import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:driver/Data/accountProvider.dart';
import 'package:driver/Data/image.dart';
import 'package:driver/Data/userData.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/models/userAddress.dart';
import 'package:driver/services/assistantmethod.dart';
import 'package:driver/views/Dashboard.dart';
import 'package:driver/views/Welcome.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

// ignore: must_be_immutable
class Maps extends StatefulWidget {
  FirebaseApp app;
  Maps({required this.app});
  @override
  _MapsState createState() => _MapsState(app: app);
}

class _MapsState extends State<Maps> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  FirebaseApp app;
  _MapsState({required this.app});
  late StreamSubscription<Position> subs;
  final geo = Geoflutterfire();
  late Stream<Position> DriverLocStream;
  var username, email, ph, image, provider, uid;
  final CameraPosition _initpostion = CameraPosition(
    target: LatLng(18.9217, 72.8332),
    zoom: 17.1414,
  );
  bool _status = false;
  late GoogleMapController newmapcontroller;

  Completer<GoogleMapController> mapcontroller = Completer();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late Position currentPosition;
  StreamSubscription<Position>? positionStream;
  final _firestore = FirebaseFirestore.instance;
  var geoLocator = Geolocator();
  void track() async {
    positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen(
      (Position position) {
        LatLng latLngPosition = LatLng(position.latitude, position.longitude);
        CameraPosition cameraPosition =
            CameraPosition(target: latLngPosition, zoom: 19);
        newmapcontroller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        print(position.toString().length == 0
            ? 'Unknown'
            : position.latitude.toString() +
                ', ' +
                position.longitude.toString());
      },
    );
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 18);
    print("latlng :-$latLngPosition");
    newmapcontroller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  void getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    var res = await Geocoding().getAddress(position, context);
    print(" This is -$res");
  }

  void logoutgoogleuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('Username');
    await prefs.remove('Email');
    await prefs.remove('Ph');
    await prefs.remove('Uid');
    await FirebaseAuth.instance.signOut();
    UserAccount userAccount =
        UserAccount(Email: "", Image: "", Ph: "", Uid: "", Username: "");
    Provider.of<AccountProvider>(context, listen: false)
        .updateuseraccount(userAccount);
    Provider.of<UserData>(context, listen: false)
        .updatepickuplocation(UserAddress(placeAddres: "", lat: 0, lng: 0));
    Get.off(
      Welcome(app: app),
    );
  }

  Future<void> getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      username = prefs.get("Username");
      email = prefs.get("Email");
      ph = prefs.get("Ph");
      image = prefs.get("Image");
      uid = prefs.get("Uid");
      print(
          "Username :- $username,Email :- $email,phone number :- $ph,Image :- $image,Uid :- $uid");
    } catch (e) {}
  }

  void onlineoffline() async {
    var collectionReference = _firestore.collection('Locations');
    var geoRef = geo.collection(collectionRef: collectionReference);
    // adding tempDrivers
    print("_status: $_status");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setBool("status", _status);
    if (_status) {
      print('in if case statsus');
      Position _currentPosition = await Geolocator.getCurrentPosition();
      try {
        GeoFirePoint myLocation = geo.point(
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude);

        DriverLocStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high);

        subs = DriverLocStream.listen((Position position) {
          geoRef.setPoint(uid, username, position.latitude, position.longitude);
        });
        Stream<dynamic> data = geoRef.within(
            center: myLocation,
            radius: 50,
            field: 'Location',
            strictMode: true);
        data.listen((dynamic loc) {
          print(loc);
        });
      } catch (e) {
        print("Error: $e");
      }
      print(
          "location lat :${_currentPosition.latitude} and long:${_currentPosition.longitude}");
    } else {
      print('in else case statsus');
      try {
        geoRef.delete(uid);
        subs.cancel();
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (context) => AccountProvider(),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.878,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.815,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      indoorViewEnabled: true,
                      minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                      initialCameraPosition: _initpostion,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      compassEnabled: false,
                      mapToolbarEnabled: true,
                      trafficEnabled: false,
                      buildingsEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        mapcontroller.complete(controller);
                        newmapcontroller = controller;
                        print("Locating ");
                        locatePosition();
                      },
                    ),
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.12,
                    maxChildSize: 0.4,
                    builder: (BuildContext buildContext,
                        ScrollController scrollController) {
                      return Container(
                        height: 250.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 16.5,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            )
                          ],
                        ),
                        child: ListView(
                          controller: scrollController,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Icon(Icons.keyboard_arrow_up_sharp),
                                  ),
                                  Text(
                                    "Hi there,",
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w100),
                                  ),
                                  Text(
                                    Provider.of<AccountProvider>(context)
                                        .userAccount
                                        .Username
                                        .capitalize
                                        .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w200,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        SharedPreferences Sp =
                                            await SharedPreferences
                                                .getInstance();
                                        try {
                                          if (Sp.getBool('status') == null) {
                                            _status = Sp.getBool("status")!;
                                          }
                                        } catch (e) {}
                                        setState(() {
                                          _status = !_status;
                                          onlineoffline();
                                        });
                                      },
                                      icon: _status
                                          ? Icon(Icons.gps_off_rounded)
                                          : Icon(Icons.gps_fixed_rounded),
                                      label: _status
                                          ? Text("Go Offline")
                                          : Text("Go Online"),
                                      style: TextButton.styleFrom(
                                        primary: _status
                                            ? Colors.redAccent
                                            : Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: _status
                                              ? BorderSide(
                                                  color: Colors.redAccent,
                                                )
                                              : BorderSide(
                                                  color: Colors.green,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black38,
                                                  blurRadius: 10.0,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 1.0)
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                LineIcons.wallet,
                                                size: 40,
                                                color: Color.fromRGBO(
                                                    122, 45, 0, 1),
                                              ),
                                              Text(
                                                "Today's Earning",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w200),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Text(
                                                "700 Rs",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w200,
                                                    color: Colors.green),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black38,
                                                  blurRadius: 10.0,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 1.0)
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.timelapse_rounded,
                                                size: 40,
                                              ),
                                              Text(
                                                "Total Online Time",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w200),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Text(
                                                "3 Hr",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w200,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    subs.cancel();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }
}

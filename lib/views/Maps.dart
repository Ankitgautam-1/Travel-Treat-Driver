import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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

class _MapsState extends State<Maps> {
  FirebaseApp app;
  _MapsState({required this.app});
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
    try {
      await GoogleSignIn().signOut();
    } catch (e) {}
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

  @override
  void initState() {
    getData();
    super.initState();
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
          "Useename :- $username,Email :- $email,phone number :- $ph,Image :- $image,Uid :- $uid");
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
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
              height: MediaQuery.of(context).size.height * 0.958,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.88,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, .5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: "Menu",
                        onPressed: () {
                          _scaffoldKey.currentState!.openDrawer();
                        },
                        icon: Icon(Icons.menu),
                      ),
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
                                      onPressed: () {
                                        setState(() {
                                          _status = !_status;
                                        });
                                      },
                                      icon: _status
                                          ? Icon(Icons.gps_fixed_rounded)
                                          : Icon(Icons.gps_off_rounded),
                                      label: _status
                                          ? Text("Go Online")
                                          : Text("Go Offline"),
                                      style: TextButton.styleFrom(
                                        primary: _status
                                            ? Colors.green
                                            : Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: _status
                                                ? BorderSide(
                                                    color: Colors.green)
                                                : BorderSide(
                                                    color: Colors.redAccent)),
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
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.close,
                                                size: 40,
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
          drawer: Drawer(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  profile(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget profile() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.958,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Color.fromRGBO(30, 30, 30, 1),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Provider.of<AccountProvider>(context, listen: false)
                          .userAccount
                          .Image
                          .toString()
                          .contains("http")
                      ? CircleAvatar(
                          backgroundColor: Colors.black26,
                          radius: 55,
                          backgroundImage: CachedNetworkImageProvider(
                              Provider.of<AccountProvider>(context,
                                      listen: false)
                                  .userAccount
                                  .Image),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.black26,
                          radius: 55,
                          backgroundImage: FileImage(
                              Provider.of<ImageData>(context, listen: false)
                                  .image!),
                        ),
                ),
                SizedBox(
                  height: 35,
                ),
                Text(
                  Provider.of<AccountProvider>(context).userAccount.Username,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  Provider.of<AccountProvider>(context).userAccount.Email,
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home_rounded,
            ),
            title: Text('Home'),
            selected: true,
            onTap: () {
              print("Home visited");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_box,
            ),
            title: Text('Account'),
            selected: false,
            onTap: () {
              print("accont visited");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.car_rental,
            ),
            title: Text('My trips'),
            selected: false,
            onTap: () {
              print("Trip visited");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
            ),
            title: Text('Settings'),
            selected: false,
            onTap: () {
              print("settings visited");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
            ),
            title: Text('Log Out'),
            selected: false,
            onTap: () {
              logoutgoogleuser();
            },
          ),
        ],
      ),
    );
  }
}

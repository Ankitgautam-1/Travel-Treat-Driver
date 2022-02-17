import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/Utils/Utils.dart';
import 'package:driver/models/Direction_provider.dart';
import 'package:driver/services/getDirections.dart';
import 'package:driver/views/Settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:driver/Data/accountProvider.dart';
import 'package:driver/Data/image.dart';
import 'package:driver/Data/userData.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/models/userAddress.dart';
import 'package:driver/services/assistantmethod.dart';
import 'package:driver/services/sending_notification.dart';
import 'package:driver/views/Dashboard.dart';
import 'package:driver/views/Welcome.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool trip_details = false;
  final box = GetStorage();
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
  String userstoken = "";
  Completer<GoogleMapController> mapcontroller = Completer();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late Position currentPosition;
  StreamSubscription<Position>? positionStream;
  late Stream timer_stream;
  final _firestore = FirebaseFirestore.instance;
  var geoLocator = Geolocator();
  double timerforreq = 0;
  String user_pickup_lat = "";
  String user_image = "";
  String user_name = "";
  String user_phone = "";
  String user_pickup_long = "";
  String user_destination_lat = "";
  String user_destination_long = "";
  String user_pickup_address = "";
  String user_destination_address = "";
  String user_trip_charge = "";
  String user_trip_distance = "";
  String user_trip_time = "";
  String user_uid = "";

  List<Marker> placeMarker = [];
  void track() async {
    positionStream = Geolocator.getPositionStream().listen(
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

  Future<void> setupnotification() async {
    print("in");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails("chnanelId", "channellname",
              channelDescription:
                  "The Travel Treat app requires notification service to assure user and alert on required time.",
              importance: Importance.high,
              priority: Priority.high);
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      if (message.data["type"] == "Ride req") {
        print("Message type${message.data["type"]}");

        dynamic userData = jsonDecode(message.data["userData"]);
        userstoken = userData["usertoken"];
        user_uid = userData["user_uid"];
        user_image = userData["image"];
        user_phone = userData["phone"];
        user_name = userData["username"];
        user_pickup_lat = userData["pickuploc"]["lat"];
        user_pickup_long = userData["pickuploc"]["long"];
        user_pickup_address = userData["pickup"];
        user_destination_lat = userData["destinationloc"]["lat"];
        user_destination_long = userData["destinationloc"]["long"];
        user_destination_address = userData["destination"];
        user_trip_charge = userData["amount"];
        user_trip_distance = userData["travel_distance"];
        user_trip_time = userData["travel_time"];

        showDialog(
            useSafeArea: true,
            barrierDismissible: false,
            context: context,
            builder: (context) {
              timer_stream = Stream.periodic(Duration(seconds: 1), (time) {
                print("time $time");
                return time;
              });
              Future.delayed(Duration(seconds: 201), () {
                while (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }
              });
              return AlertDialog(
                content: StreamBuilder(
                    initialData: 0,
                    stream: timer_stream,
                    builder: (builder, ctx) {
                      return SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(4),
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: min(
                            350,
                            MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: (double.tryParse(ctx.data.toString())! /
                                    201),
                                backgroundColor: Colors.grey.shade400,
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.grey.shade700),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircularProfileAvatar(
                                    userData["image"],
                                    imageFit: BoxFit.cover,
                                    radius: 45,
                                    cacheImage: true,
                                    initialsText: Text(userData["username"]
                                        .toString()
                                        .substring(0, 1)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData["username"],
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "${userData["travel_distance"]} Km | ${userData["travel_time"]} Min",
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Text(
                                "Pickup",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  userData["pickup"],
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600),
                                ),
                              ),
                              Text(
                                "Destination",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  userData["destination"],
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              SlideAction(
                                text: "Slide to accept",
                                textStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                sliderButtonIconPadding: 9,
                                height: 40,
                                sliderButtonIconSize: 20,
                                sliderButtonIcon: Icon(
                                  Iconsax.arrow_right_1,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                onSubmit: () {
                                  Future.delayed(Duration(seconds: 1),
                                      () async {
                                    Position drivers_position =
                                        await Geolocator.getCurrentPosition();
                                    List? the_data = await Directions(
                                            context: context,
                                            origin:
                                                "${drivers_position.latitude.toString()},${drivers_position.longitude.toString()}",
                                            destination:
                                                "$user_pickup_lat,$user_pickup_long",
                                            endpoint: "FindDrivingPath")
                                        .getDirections();
                                    String drivers_token =
                                        await FirebaseMessaging.instance
                                                .getToken() ??
                                            "";
                                    placeMarker.add(Marker(
                                        markerId: MarkerId("Users_Location"),
                                        icon: BitmapDescriptor
                                            .defaultMarkerWithHue(
                                                BitmapDescriptor.hueMagenta),
                                        infoWindow:
                                            InfoWindow(title: "Meet Place"),
                                        position: LatLng(
                                            double.tryParse(user_pickup_lat)!,
                                            double.tryParse(
                                                user_pickup_long)!)));

                                    setState(() {
                                      trip_details = true;
                                    });
                                    print("the_data[1] ${the_data}");
                                    Msg().sendAcceptRidereq(
                                        Provider.of<AccountProvider>(context,
                                                listen: false)
                                            .userAccount
                                            .Uid,
                                        Provider.of<AccountProvider>(context,
                                                listen: false)
                                            .userAccount
                                            .Username,
                                        Provider.of<AccountProvider>(context,
                                                listen: false)
                                            .userAccount
                                            .Ph,
                                        userstoken,
                                        drivers_position.latitude.toString(),
                                        drivers_position.longitude.toString(),
                                        the_data![1],
                                        Provider.of<AccountProvider>(context,
                                                listen: false)
                                            .userAccount
                                            .CarModel,
                                        Provider.of<AccountProvider>(context,
                                                listen: false)
                                            .userAccount
                                            .CarNumber,
                                        Provider.of<AccountProvider>(context,
                                                listen: false)
                                            .userAccount
                                            .rating,
                                        drivers_token);
                                    while (Navigator.of(context,
                                            rootNavigator: true)
                                        .canPop()) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    }
                                  });
                                },
                                innerColor: Colors.green.shade700,
                                outerColor: Colors.white,
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              SlideAction(
                                submittedIcon: Icon(
                                  Iconsax.close_circle4,
                                  size: 15,
                                  color: Colors.red.shade700,
                                ),
                                text: "Slide to cancel",
                                textStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                sliderButtonIconPadding: 9,
                                height: 40,
                                sliderButtonIconSize: 20,
                                reversed: true,
                                sliderButtonIcon: Icon(
                                  Iconsax.close_circle4,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                onSubmit: () {
                                  // Msg.sendCancelRidereq(userstoken);
                                  Future.delayed(Duration(seconds: 1), () {
                                    while (Navigator.of(context,
                                            rootNavigator: true)
                                        .canPop()) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    }
                                  });
                                },
                                innerColor: Colors.red.shade600,
                                outerColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              );
            });
      } else if (message.data["type"] == "Ride cancel") {
        while (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
      } else {
        print("notification");
        // Navigator.of(context).pop(true);
        await FlutterLocalNotificationsPlugin()
            .show(12345, "${message.category}", "${message.data["type"]}",
                platformChannelSpecifics,
                payload: 'sending from user')
            .then((value) => print(" print done"))
            .onError((error, stackTrace) => print("got error"));
      }
    });
  }

  void logoutgoogleuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('Username');
    await prefs.remove('Email');
    await prefs.remove('Ph');
    await prefs.remove('Uid');
    await FirebaseAuth.instance.signOut();
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

  Future<void> tripinprogress() async {
    var collectionReference = _firestore.collection('Test_Loc');
    var geoRef = geo.collection(collectionRef: collectionReference);
    geoRef.delete(
        Provider.of<AccountProvider>(context, listen: false).userAccount.Uid);
    collectionReference = _firestore.collection('Trip_in_progress');

    try {
      subs.cancel();
      subs = DriverLocStream.listen(
        (Position position) async {
          GeoFirePoint current = geo.point(
              latitude: position.latitude, longitude: position.longitude);
          final snapShot = await collectionReference.doc(user_uid).get();
          print("snapshot:${snapShot.exists}");

          String token = await FirebaseMessaging.instance.getToken() ?? "";
          if (snapShot.exists) {
            collectionReference.doc(user_uid).update(
              {'uid': uid, "position": current.data},
            );
          } else {
            print(
                "Driver online ${Provider.of<AccountProvider>(context, listen: false).userAccount.CarUrl}");
            collectionReference.doc(user_uid).set(
              {
                "driverDetails": {
                  "imageurl":
                      Provider.of<AccountProvider>(context, listen: false)
                          .userAccount
                          .Image,
                  "rating": Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .rating,
                  "username":
                      Provider.of<AccountProvider>(context, listen: false)
                          .userAccount
                          .Username,
                },
                "carDetails": {
                  "carImage":
                      Provider.of<AccountProvider>(context, listen: false)
                          .userAccount
                          .CarUrl,
                  "class": Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .CarClass,
                  "carModel":
                      Provider.of<AccountProvider>(context, listen: false)
                          .userAccount
                          .CarModel,
                  "carNumber":
                      Provider.of<AccountProvider>(context, listen: false)
                          .userAccount
                          .CarNumber,
                  "usersDetails": {
                    "userstoken": userstoken,
                    "user_uid": user_uid,
                    "user_image": user_image,
                    "user_phone": user_phone,
                    "user_name": user_name,
                    "user_pickup_lat": user_pickup_lat,
                    "user_pickup_long": user_pickup_long,
                    "user_pickup_address": user_pickup_address,
                    "user_destination_lat": user_destination_lat,
                    "user_destination_long": user_destination_long,
                    "user_destination_address": user_destination_address,
                    "user_trip_charge": user_trip_charge,
                    "user_trip_distance": user_trip_distance,
                    "user_trip_time": user_trip_time,
                  }
                },
                'uid': uid,
                "position": current.data,
                "username": username,
                "token": token,
              },
            );
          }
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  void onlineoffline() async {
    var collectionReference = _firestore.collection('Test_Loc');
    var geoRef = geo.collection(collectionRef: collectionReference);
    // adding tempDrivers
    print("_status: $_status");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setBool("status", _status);
    if (_status) {
      box.write('driver_status', true);
      print('in if case statsus');
      Position _currentPosition = await Geolocator.getCurrentPosition();
      try {
        GeoFirePoint myLocation = geo.point(
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude);

        DriverLocStream = Geolocator.getPositionStream();

        subs = DriverLocStream.listen(
          (Position position) async {
            GeoFirePoint current = geo.point(
                latitude: position.latitude, longitude: position.longitude);
            final snapShot = await collectionReference.doc(uid).get();
            print("snapshot:${snapShot.exists}");

            String token = await FirebaseMessaging.instance.getToken() ?? "";
            if (snapShot.exists) {
              collectionReference.doc(uid).update(
                {'uid': uid, "position": current.data},
              );
            } else {
              print(
                  "Driver online ${Provider.of<AccountProvider>(context, listen: false).userAccount.CarUrl}");
              collectionReference.doc(uid).set(
                {
                  "driverDetails": {
                    "imageurl":
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .Image,
                    "rating":
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .rating,
                    "username":
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .Username,
                  },
                  "carDetails": {
                    "carImage":
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .CarUrl,
                    "class":
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .CarClass,
                    "carModel":
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .CarModel,
                    "carNumber":
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .CarNumber,
                  },
                  'uid': uid,
                  "position": current.data,
                  "username": username,
                  "token": token
                },
              );
            }
          },
        );
      } catch (e) {
        print("Error: $e");
      }
      print(
          "location lat :${_currentPosition.latitude} and long:${_currentPosition.longitude}");
    } else {
      print('in else case statsus');
      try {
        geoRef.delete(uid);
        box.write('driver_status', false);
        subs.cancel();
      } catch (e) {}
    }
  }

  Widget profile() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.96,
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
                Hero(
                  tag: "profile",
                  child: GestureDetector(
                    onTap: () {
                      Get.to(Accounts());
                    },
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: Image.network(
                            Provider.of<AccountProvider>(context, listen: false)
                                .userAccount
                                .Image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Text(
                  Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Username,
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Email,
                  style:
                      GoogleFonts.openSans(fontSize: 13, color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Colors.black,
            ),
            title: Text(
              'Log Out',
              style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600, color: Colors.black),
            ),
            selected: false,
            onTap: () {
              logoutgoogleuser();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _status = box.read('driver_status') ?? false;
    super.build(context);
    setupnotification();
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
          drawer: Drawer(
            elevation: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  profile(),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.945,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.85,
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
                        markers: Set.from(placeMarker),
                        polylines:
                            Provider.of<DirectionsProvider>(context).polylines,
                        mapToolbarEnabled: true,
                        trafficEnabled: false,
                        buildingsEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          controller.setMapStyle(mapstyle);
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
                          color: Color.fromRGBO(255, 255, 255, .7),
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
                          child: !trip_details
                              ? ListView(
                                  controller: scrollController,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0, vertical: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Icon(
                                                Icons.keyboard_arrow_up_sharp),
                                          ),
                                          Text(
                                            "Hi there,",
                                            style: GoogleFonts.openSans(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 8.0,
                                          ),
                                          Center(
                                            child: TextButton.icon(
                                              onPressed: () async {
                                                SharedPreferences Sp =
                                                    await SharedPreferences
                                                        .getInstance();
                                                try {
                                                  if (Sp.getBool('status') ==
                                                      null) {
                                                    _status =
                                                        Sp.getBool("status")!;
                                                  }
                                                } catch (e) {}
                                                setState(() {
                                                  _status = !_status;
                                                  onlineoffline();
                                                });
                                              },
                                              icon: _status
                                                  ? Icon(Icons.gps_off_rounded)
                                                  : Icon(
                                                      Icons.gps_fixed_rounded),
                                              label: _status
                                                  ? Text(
                                                      "Go Offline",
                                                      style:
                                                          GoogleFonts.openSans(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Go Online",
                                                      style:
                                                          GoogleFonts.openSans(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                              style: TextButton.styleFrom(
                                                primary: _status
                                                    ? Colors.redAccent
                                                    : Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  side: _status
                                                      ? BorderSide(
                                                          color:
                                                              Colors.redAccent,
                                                        )
                                                      : BorderSide(
                                                          color: Colors.green,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                child: Image.network(
                                                    Provider.of<AccountProvider>(
                                                            context,
                                                            listen: false)
                                                        .userAccount
                                                        .Image,
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "${Provider.of<AccountProvider>(context, listen: false).userAccount.Username}",
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  Text(
                                                      "${Provider.of<AccountProvider>(context, listen: false).userAccount.Email}"
                                                                  .length >
                                                              18
                                                          ? "${Provider.of<AccountProvider>(context, listen: false).userAccount.Email.substring(0, 15) + "..."}"
                                                          : " ${Provider.of<AccountProvider>(context, listen: false).userAccount.Email}",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black45))
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    LineIcons.starAlt,
                                                    color: Colors.amber,
                                                  ),
                                                  Text(
                                                    "  ${Provider.of<AccountProvider>(context, listen: false).userAccount.rating}",
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 15,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Image.network(
                                                  '${Provider.of<AccountProvider>(context, listen: false).userAccount.CarUrl}',
                                                  width: 140,
                                                  height: 90,
                                                  fit: BoxFit.cover),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${Provider.of<AccountProvider>(context, listen: false).userAccount.CarModel}',
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    '${Provider.of<AccountProvider>(context, listen: false).userAccount.CarNumber}',
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 15,
                                                      color: Colors.black54,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView(
                                  controller: scrollController,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0, vertical: 18.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.arrow_drop_up_rounded,
                                                size: 30,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                child: Image.network(
                                                    '${user_image}',
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("${user_name}",
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  Text("${user_phone}",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black45))
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    LineIcons.starAlt,
                                                    color: Colors.amber,
                                                  ),
                                                  Text(
                                                    "  4.5",
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 15,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  FaIcon(Iconsax.map5),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      "${user_trip_distance}" +
                                                          " KM",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black45))
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Iconsax.clock5),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      "${user_trip_time}" +
                                                          " Min",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black45))
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(' \u{20B9}',
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontSize: 20,
                                                              color: Colors
                                                                  .black)),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      "${user_trip_charge}" +
                                                          " Rupees",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black45))
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Icon(Icons.my_location_rounded),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "${user_pickup_address}",
                                                  style: GoogleFonts.openSans(
                                                      fontSize: 16,
                                                      color: Colors.black54),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_on_rounded),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "${user_destination_address}",
                                                  style: GoogleFonts.openSans(
                                                      fontSize: 16,
                                                      color: Colors.black54),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.black,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 20,
                                                    )),
                                                onPressed: () {
                                                  launch(
                                                      "tel://${user_phone}}");
                                                },
                                                icon: Icon(
                                                  Icons.phone,
                                                  color: Colors.white,
                                                ),
                                                label: Text(" Call",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white)),
                                              ),
                                              TextButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.black,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 20,
                                                    )),
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.cancel_outlined,
                                                  color: Colors.white,
                                                ),
                                                label: Text(" Cancel Ride",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white)),
                                              )
                                            ],
                                          )
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
      ),
    );
  }

  @override
  void dispose() {
    try {
      subs.cancel();
    } catch (e) {}
    super.dispose();
  }

  void getnotification() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails("chnanelId", "channellname",
            channelDescription:
                "The Travel Treat app requires notification service to assure user and alert on required time.",
            importance: Importance.high,
            priority: Priority.high);
  }

  @override
  void initState() {
    getData();
    getnotification();
    setupnotification();
    super.initState();
  }
}

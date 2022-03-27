import 'dart:async';
import 'dart:convert';

import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/Data/connectivityProvider.dart';
import 'package:driver/Data/ratingProvider.dart';
import 'package:driver/Utils/Utils.dart';
import 'package:driver/models/Direction_provider.dart';
import 'package:driver/services/getDirections.dart';
import 'package:driver/views/Settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';

import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:driver/Data/accountProvider.dart';

import 'package:driver/Data/userData.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/models/userAddress.dart';
import 'package:driver/services/assistantmethod.dart';
import 'package:driver/services/sending_notification.dart';

import 'package:driver/views/Welcome.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pinput/pin_put/pin_put.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

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
  bool isinmidtrip = false;
  bool trip_details = false;
  late LatLng pickup;
  final box = GetStorage();
  _MapsState({required this.app});
  late StreamSubscription<Position> subs;
  final geo = Geoflutterfire();
  late Stream<Position> DriverLocStream;
  var username, email, ph, image, provider, uid;
  String trip_docid = "";
  loc.Location location = new loc.Location();
  final CameraPosition _initpostion = CameraPosition(
    target: LatLng(18.9217, 72.8332),
    zoom: 17.1414,
  );
  LatLng destination = LatLng(18.9217, 72.8332);
  bool _status = false;
  late GoogleMapController newmapcontroller;
  String userstoken = "";
  bool isConnected = false;
  Completer<GoogleMapController> mapcontroller = Completer();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late Position currentPosition;
  String otp = "";
  StreamSubscription<Position>? positionStream;
  final _firestore = FirebaseFirestore.instance;
  var geoLocator = Geolocator();
  double timerforreq = 0;
  String user_pickup_lat = "";
  String user_image = "";
  String user_name = "";
  String user_phone = "";
  String user_pickup_long = "";
  String verificationId = "";
  String user_destination_lat = "";
  String user_destination_long = "";
  String user_pickup_address = "";
  String user_destination_address = "";
  String user_trip_charge = "";
  String user_trip_distance = "";
  String user_trip_time = "";
  String user_rating = "";
  String user_uid = "";
  String cab_type = "";
  String payment_type = "";
  String user_email = "";
  String user_token = "";
  bool goingtopicup = false;
  String startTrip = "";
  late Directions directions;
  late Timer timer;

  TextEditingController reviewController = TextEditingController(text: '');
  TextEditingController reviewMessageController =
      TextEditingController(text: '');
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

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
        user_token = userData["usertoken"];
        user_trip_charge = userData["amount"];
        user_trip_distance = userData["travel_distance"];
        user_trip_time = userData["travel_time"];
        user_rating = userData["user_rating"];
        cab_type = userData["cab_type"];
        startTrip = DateTime.now().toString();
        payment_type = userData["payment_type"];
        user_email = userData["user_email"];

        showDialog(
            useSafeArea: true,
            barrierDismissible: false,
            context: context,
            builder: (context) {
              timer = Timer(Duration(seconds: 201), () {
                while (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }
              });

              return AlertDialog(
                content: StreamBuilder(
                    initialData: 0,
                    stream: Stream.periodic(Duration(seconds: 1), (time) {
                      return time;
                    }),
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
                                    tripinprogress().then((value) {
                                      if (value) {
                                        Msg()
                                            .sendAcceptRidereq(
                                                Provider.of<AccountProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAccount
                                                    .Uid,
                                                Provider.of<AccountProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAccount
                                                    .Username,
                                                Provider.of<
                                                            AccountProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAccount
                                                    .Ph,
                                                userstoken,
                                                drivers_position.latitude
                                                    .toString(),
                                                drivers_position.longitude
                                                    .toString(),
                                                the_data![1],
                                                Provider.of<AccountProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAccount
                                                    .CarModel,
                                                Provider.of<AccountProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAccount
                                                    .CarNumber,
                                                Provider.of<AccountProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAccount
                                                    .rating,
                                                drivers_token)
                                            .then((value) {
                                          while (Navigator.of(context,
                                                  rootNavigator: true)
                                              .canPop()) {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                          }
                                          if (!(Navigator.of(context,
                                                  rootNavigator: true)
                                              .canPop())) {
                                            timer.cancel();
                                            var geoRef = geo.collection(
                                                collectionRef: _firestore
                                                    .collection('Test_Loc'));
                                            geoRef.delete(
                                                Provider.of<AccountProvider>(
                                                        context,
                                                        listen: false)
                                                    .userAccount
                                                    .Uid);
                                          }
                                        });
                                      } else {
                                        Get.snackbar("The Ride ",
                                            "Something went wrong please try again",
                                            duration: Duration(seconds: 4));
                                      }
                                    });
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
                                  Msg().sendCancelRidereq(userstoken);
                                  Future.delayed(Duration(seconds: 1), () {
                                    while (Navigator.of(context,
                                            rootNavigator: true)
                                        .canPop()) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    }
                                    timer.cancel();
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
      } else if (message.data["type"] == "Cancel Trip") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isinmidtrip", false);
        prefs.setString("user_uid", "");
        print("checkisinmidtrip");
        placeMarker = [];

        var response = prefs.setBool("isinmidtrip", false);
        Provider.of<DirectionsProvider>(context, listen: false)
            .updateDirectionsProvider(null, null, 0, 0, {});
        var collectionReference = _firestore.collection('Trip_in_progress');
        var geoRef = geo.collection(collectionRef: collectionReference);
        geoRef.delete(user_uid);
        subs.cancel();
        setState(() {
          trip_details = false;
          isinmidtrip = false;

          prefs.setBool("status", false);
        });
      } else if (message.data["type"] == "Payment Cash") {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ClassicGeneralDialogWidget(
                actions: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Payment (Cash)",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          Image.asset('asset/images/cash_pay.png'),
                          Text(
                            "Total Amount: ${user_trip_charge}" + " Rupees",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedTextKit(
                            animatedTexts: [
                              ColorizeAnimatedText(
                                "Waiting for Your Confirmation",
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                colors: [
                                  Colors.grey.shade900,
                                  Colors.grey.shade300,
                                ],
                              ),
                            ],
                            repeatForever: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: Colors.black,
                                primary: Colors.white,
                              ),
                              onPressed: () {
                                DateTime now = DateTime.now();
                                var current_time = now.toLocal().toString();
                                var collectionReference =
                                    _firestore.collection('Trip_collection');
                                trip_docid = user_uid + "_" + current_time;
                                Msg()
                                    .sendCashPaymentApprove(
                                        userstoken, trip_docid)
                                    .then((value) {
                                  collectionReference
                                      .doc(user_uid + "_" + current_time)
                                      .set({
                                    "userDetails": {
                                      "user_uid": user_uid,
                                      "user_image": user_image,
                                      "user_phone": user_phone,
                                      "user_name": user_name,
                                      "user_pickup_lat": user_pickup_lat,
                                      "user_pickup_long": user_pickup_long,
                                      "user_pickup_address":
                                          user_pickup_address,
                                      "user_destination_lat":
                                          user_destination_lat,
                                      "user_destination_long":
                                          user_destination_long,
                                      "user_destination_address":
                                          user_destination_address,
                                      "user_trip_charge": user_trip_charge,
                                      "user_trip_distance": user_trip_distance,
                                      "user_trip_time": user_trip_time,
                                      "user_email": user_email
                                    },
                                    'driverDetails': {
                                      'driver_uid':
                                          Provider.of<AccountProvider>(context,
                                                  listen: false)
                                              .userAccount
                                              .Uid,
                                      'driver_profile':
                                          Provider.of<AccountProvider>(context,
                                                  listen: false)
                                              .userAccount
                                              .Image,
                                      'driver_email':
                                          Provider.of<AccountProvider>(context,
                                                  listen: false)
                                              .userAccount
                                              .Email,
                                      'driver_name':
                                          Provider.of<AccountProvider>(context,
                                                  listen: false)
                                              .userAccount
                                              .Username,
                                      'driver_phone':
                                          Provider.of<AccountProvider>(context,
                                                  listen: false)
                                              .userAccount
                                              .Ph,
                                      'driver_rating':
                                          Provider.of<AccountProvider>(context,
                                                  listen: false)
                                              .userAccount
                                              .rating,
                                    },
                                    'cabDetails': {
                                      "cab_type": Provider.of<AccountProvider>(
                                              context,
                                              listen: false)
                                          .userAccount
                                          .CarClass,
                                      "cab_number":
                                          Provider.of<AccountProvider>(context,
                                                  listen: false)
                                              .userAccount
                                              .CarNumber,
                                      "cab_image": Provider.of<AccountProvider>(
                                              context,
                                              listen: false)
                                          .userAccount
                                          .CarUrl,
                                    },
                                    'paymentDetails': {
                                      "payment_type": payment_type,
                                      "payment_amount": user_trip_charge,
                                      "payment_time": current_time,
                                    },
                                    "trip_end_time": current_time,
                                    'startTrip': startTrip,
                                  }).then((value) async {
                                    collectionReference = _firestore
                                        .collection('Trip_in_progress');
                                    collectionReference
                                        .doc(user_uid)
                                        .delete()
                                        .then((e) {
                                      subs.cancel();
                                    });
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool("isinmidtrip", false);
                                    prefs.setString("user_uid", "");

                                    var response =
                                        prefs.setBool("isinmidtrip", false);
                                    setState(() {
                                      placeMarker = [];
                                      Provider.of<DirectionsProvider>(context,
                                              listen: false)
                                          .updateDirectionsProvider(
                                              null, null, 0, 0, {});
                                      var collectionReference = _firestore
                                          .collection('Trip_in_progress');
                                      var geoRef = geo.collection(
                                          collectionRef: collectionReference);
                                      geoRef.delete(user_uid);
                                      subs.cancel();
                                      setState(() {
                                        trip_details = false;
                                        isinmidtrip = false;

                                        prefs.setBool("status", false);
                                      });
                                    });
                                    while (Navigator.of(context,
                                            rootNavigator: true)
                                        .canPop()) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    }
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (builder) {
                                          return ClassicGeneralDialogWidget(
                                            actions: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 6),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Trip Reviews",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 20),
                                                      ),
                                                      AnimatedTextKit(
                                                        animatedTexts: [
                                                          ColorizeAnimatedText(
                                                              "Share Your Ride Experience",
                                                              textStyle:
                                                                  GoogleFonts
                                                                      .poppins(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              colors: [
                                                                Colors.grey
                                                                    .shade900,
                                                                Colors.grey
                                                                    .shade300,
                                                              ]),
                                                        ],
                                                        repeatForever: true,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            child:
                                                                Image.network(
                                                                    user_image,
                                                                    width: 70,
                                                                    height: 70,
                                                                    fit: BoxFit
                                                                        .cover),
                                                          ),
                                                          SizedBox(
                                                            width: 30,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(user_name,
                                                                  style: GoogleFonts.roboto(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600)),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    LineIcons
                                                                        .starAlt,
                                                                    color: Colors
                                                                        .amber,
                                                                  ),
                                                                  Text(
                                                                    user_rating,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: GoogleFonts
                                                                        .dmSans(
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 40,
                                                        child: Row(
                                                          children: [
                                                            Consumer<
                                                                    RatingProvider>(
                                                                builder:
                                                                    (context,
                                                                        value,
                                                                        _) {
                                                              return RatingBarIndicator(
                                                                rating: value
                                                                    .rating,
                                                                itemBuilder:
                                                                    (context,
                                                                            index) =>
                                                                        Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                ),
                                                                itemCount: 5,
                                                                itemSize: 30.0,
                                                                direction: Axis
                                                                    .horizontal,
                                                              );
                                                            }),
                                                            Container(
                                                              width: 80,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20),
                                                              child: Center(
                                                                child:
                                                                    TextFormField(
                                                                  onChanged:
                                                                      (value) {
                                                                    if (double.parse(value) >=
                                                                            1.0 &&
                                                                        double.parse(value) <=
                                                                            5.0) {
                                                                      Provider.of<RatingProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .setRating(
                                                                              double.parse(value));
                                                                    }
                                                                  },
                                                                  controller:
                                                                      reviewController,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  cursorColor:
                                                                      Colors
                                                                          .black,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            top:
                                                                                6,
                                                                            left:
                                                                                12),
                                                                    hintText:
                                                                        '4.4',
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        Colors.grey[
                                                                            300],
                                                                    focusColor:
                                                                        Colors
                                                                            .black,
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      SizedBox(
                                                        height: 35,
                                                        width: 250,
                                                        child: TextFormField(
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                          controller:
                                                              reviewMessageController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          cursorColor:
                                                              Colors.black,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    top: 6,
                                                                    left: 12),
                                                            hintText:
                                                                "Write a review",
                                                            hintStyle: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                            focusColor:
                                                                Colors.black,
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              borderSide:
                                                                  BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        width: 250,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  padding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          30),
                                                                  primary: Colors
                                                                      .black,
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                onPressed: () {
                                                                  if (reviewMessageController
                                                                          .text
                                                                          .trim() !=
                                                                      "") {
                                                                    var collectionReference =
                                                                        _firestore
                                                                            .collection('Trip_collection');
                                                                    collectionReference
                                                                        .doc(
                                                                            trip_docid)
                                                                        .update({
                                                                      "driver_review":
                                                                          "${reviewMessageController.text.trim()}",
                                                                    });
                                                                    var avg;
                                                                    if (reviewController
                                                                            .text
                                                                            .trim() !=
                                                                        "") {
                                                                      _firestore
                                                                          .collection(
                                                                              'Users')
                                                                          .doc(
                                                                              trip_docid)
                                                                          .get()
                                                                          .then(
                                                                              (value) {
                                                                        double
                                                                            total =
                                                                            0.0;
                                                                        var last_5_ride_rating =
                                                                            value.data()!['last_5_ride_rating'];
                                                                        last_5_ride_rating
                                                                            .removeAt(0);
                                                                        last_5_ride_rating.add(reviewController
                                                                            .text
                                                                            .trim());
                                                                        for (int i =
                                                                                0;
                                                                            i < last_5_ride_rating.length;
                                                                            i++) {
                                                                          total =
                                                                              total + double.parse(last_5_ride_rating[i]);
                                                                        }
                                                                        avg = total /
                                                                            5;
                                                                        if (avg.toString().length >
                                                                            2) {
                                                                          print(
                                                                              "real value $avg");
                                                                          avg = double.parse(avg.toString().substring(
                                                                              0,
                                                                              3));
                                                                        }
                                                                        _firestore
                                                                            .collection(
                                                                                'Users')
                                                                            .doc(
                                                                                trip_docid)
                                                                            .update({
                                                                          'rating':
                                                                              avg
                                                                        });
                                                                        Msg().sendUpdateRatingValue(
                                                                            user_token,
                                                                            avg);
                                                                      });
                                                                    }
                                                                    while (Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .canPop()) {
                                                                      Navigator.of(
                                                                              context,
                                                                              rootNavigator: true)
                                                                          .pop('dialog');
                                                                    }

                                                                    reviewMessageController
                                                                        .text = "";
                                                                  } else {
                                                                    _scaffoldKey
                                                                        .currentState!
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text("Please write a review"),
                                                                        duration:
                                                                            Duration(seconds: 2),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Text(
                                                                    "Submit",
                                                                    style: GoogleFonts.montserrat(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w400))),
                                                            ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            30),
                                                                    primary: Colors
                                                                        .white,
                                                                    onPrimary:
                                                                        Colors
                                                                            .black),
                                                                onPressed: () {
                                                                  while (Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .canPop()) {
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop(
                                                                            'dialog');
                                                                  }
                                                                },
                                                                child: Text(
                                                                    "Cancel",
                                                                    style: GoogleFonts.montserrat(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w400))),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  });
                                });
                              },
                              child: Text(
                                "Payment Approve",
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                          // Text("Waiting for Drivers Confirmation", style: GoogleFonts.poppins(color: Colors.blueGrey.shade300, fontWeight: FontWeight.w600, fontSize: 14))
                        ],
                      ),
                    ),
                  ),
                ],
              );
            });
      } else if (message.data["type"] == "Payment Online Done") {
        print("Payment Online Done HERE");
        trip_docid = message.data['trip_docid'];
        var current_time = DateTime.now().toString();
        var collectionReference = _firestore.collection('Trip_collection');
        collectionReference.doc(trip_docid).update({
          "userDetails": {
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
            "user_email": user_email
          },
          'driverDetails': {
            'driver_uid': Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .Uid,
            'driver_profile':
                Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Image,
            'driver_email': Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .Email,
            'driver_name': Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .Username,
            'driver_phone': Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .Ph,
            'driver_rating':
                Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .rating,
          },
          'cabDetails': {
            "cab_type": Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .CarClass,
            "cab_number": Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .CarNumber,
            "cab_image": Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .CarUrl,
          },
          'paymentDetails': {
            "payment_type": payment_type,
            "payment_amount": user_trip_charge,
            "payment_time": current_time,
          },
          'startTrip': startTrip,
        }).then((value) async {
          collectionReference = _firestore.collection('Trip_in_progress');
          collectionReference.doc(user_uid).delete().then((e) {
            subs.cancel();
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isinmidtrip", false);
          prefs.setString("user_uid", "");

          var response = prefs.setBool("isinmidtrip", false);
          setState(() {
            placeMarker = [];
            Provider.of<DirectionsProvider>(context, listen: false)
                .updateDirectionsProvider(null, null, 0, 0, {});
            var collectionReference = _firestore.collection('Trip_in_progress');
            var geoRef = geo.collection(collectionRef: collectionReference);
            geoRef.delete(user_uid);
            subs.cancel();
            setState(() {
              trip_details = false;
              isinmidtrip = false;
              prefs.setBool("status", false);
            });
          });

          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (builder) {
                return ClassicGeneralDialogWidget(
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 6),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              "Trip Reviews",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 20),
                            ),
                            AnimatedTextKit(
                              animatedTexts: [
                                ColorizeAnimatedText(
                                    "Share Your Ride Experience",
                                    textStyle: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    colors: [
                                      Colors.grey.shade900,
                                      Colors.grey.shade300,
                                    ]),
                              ],
                              repeatForever: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18.0),
                                  child: Image.network(user_image,
                                      width: 70, height: 70, fit: BoxFit.cover),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user_name,
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Icon(
                                          LineIcons.starAlt,
                                          color: Colors.amber,
                                        ),
                                        Text(
                                          user_rating,
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                              child: Row(
                                children: [
                                  Consumer<RatingProvider>(
                                      builder: (context, value, _) {
                                    return RatingBarIndicator(
                                      rating: value.rating,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 30.0,
                                      direction: Axis.horizontal,
                                    );
                                  }),
                                  Container(
                                    width: 80,
                                    padding: EdgeInsets.only(left: 20),
                                    child: Center(
                                      child: TextFormField(
                                        onChanged: (value) {
                                          if (double.parse(value) >= 1.0 &&
                                              double.parse(value) <= 5.0) {
                                            Provider.of<RatingProvider>(context,
                                                    listen: false)
                                                .setRating(double.parse(value));
                                          }
                                        },
                                        controller: reviewController,
                                        keyboardType: TextInputType.number,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(top: 6, left: 12),
                                          hintText: '4.4',
                                          filled: true,
                                          fillColor: Colors.grey[300],
                                          focusColor: Colors.black,
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 35,
                              width: 250,
                              child: TextFormField(
                                style: GoogleFonts.montserrat(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                                controller: reviewMessageController,
                                keyboardType: TextInputType.text,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(top: 6, left: 12),
                                  hintText: "Write a review",
                                  hintStyle: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                  focusColor: Colors.black,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 250,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 30),
                                        primary: Colors.black,
                                        onPrimary: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (reviewMessageController.text
                                                .trim() !=
                                            "") {
                                          var collectionReference = _firestore
                                              .collection('Trip_collection');
                                          collectionReference
                                              .doc(trip_docid)
                                              .update({
                                            "driver_review":
                                                "${reviewMessageController.text.trim()}",
                                          });
                                          var avg;
                                          if (reviewController.text.trim() !=
                                              "") {
                                            _firestore
                                                .collection('Users')
                                                .doc(trip_docid)
                                                .get()
                                                .then((value) {
                                              double total = 0.0;
                                              var last_5_ride_rating =
                                                  value.data()![
                                                      'last_5_ride_rating'];
                                              last_5_ride_rating.removeAt(0);
                                              last_5_ride_rating.add(
                                                  reviewController.text.trim());
                                              for (int i = 0;
                                                  i < last_5_ride_rating.length;
                                                  i++) {
                                                total = total +
                                                    double.parse(
                                                        last_5_ride_rating[i]);
                                              }
                                              avg = total / 5;
                                              if (avg.toString().length > 2) {
                                                print("real value $avg");
                                                avg = double.parse(avg
                                                    .toString()
                                                    .substring(0, 3));
                                              }
                                              _firestore
                                                  .collection('Users')
                                                  .doc(trip_docid)
                                                  .update({'rating': avg});
                                              Msg().sendUpdateRatingValue(
                                                  user_token, avg);
                                            });
                                          }
                                          while (Navigator.of(context,
                                                  rootNavigator: true)
                                              .canPop()) {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                          }

                                          reviewMessageController.text = "";
                                        } else {
                                          _scaffoldKey.currentState!
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text("Please write a review"),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text("Submit",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400))),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 30),
                                          primary: Colors.white,
                                          onPrimary: Colors.black),
                                      onPressed: () {
                                        while (Navigator.of(context,
                                                rootNavigator: true)
                                            .canPop()) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        }
                                      },
                                      child: Text("Cancel",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400))),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              });
        });
      } else {
        print("notification");

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

  Future<bool> tripinprogress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _status = false;
      goingtopicup = true;
    });
    prefs.setString("user_uid", user_uid);
    prefs.setBool("isinmidtrip", true);
    var collectionReference = _firestore.collection('Test_Loc');

    collectionReference = _firestore.collection('Trip_in_progress');
    try {
      subs.cancel();
      Stream<Position> DriverLocation = Geolocator.getPositionStream();
      String token = await FirebaseMessaging.instance.getToken() ?? "";
      subs = DriverLocation.listen(
        (Position position) async {
          GeoFirePoint current = geo.point(
              latitude: position.latitude, longitude: position.longitude);
          final snapShot = await collectionReference.doc(user_uid).get();

          if (snapShot.exists && _status) {
            collectionReference.doc(user_uid).update(
              {
                'uid': Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid,
                "position": current.data
              },
            );
          } else if (_status) {
            DateTime now = DateTime.now();
            var current_time = now.toLocal().toString();
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
                  "phone": Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Ph,
                  "username":
                      Provider.of<AccountProvider>(context, listen: false)
                          .userAccount
                          .Username,
                  "driver_token": token,
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
                    "cab_type": cab_type,
                    'user_email': user_email,
                    "payment_type": payment_type,
                    "user_rating": user_rating,
                  }
                },
                'uid': Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid,
                "position": current.data,
                "username": username,
                "token": token,
                "startTrip": current_time,
              },
            );
          } else {}
        },
      );
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<void> setDriverDetails() async {
    var collectionReference = _firestore.collection('Test_Loc');
    var geoRef = geo.collection(collectionRef: collectionReference);
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
          final snapShot = await collectionReference
              .doc(Provider.of<AccountProvider>(context, listen: false)
                  .userAccount
                  .Uid)
              .get();
          print("snapshot:${snapShot.exists}");

          String token = await FirebaseMessaging.instance.getToken() ?? "";
          if (snapShot.exists) {
            collectionReference
                .doc(Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid)
                .update(
              {
                'uid': Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid,
                "position": current.data
              },
            );
          } else {
            print(
                "Driver online ${Provider.of<AccountProvider>(context, listen: false).userAccount.CarUrl}");
            collectionReference
                .doc(Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid)
                .set(
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
                },
                'uid': Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid,
                "position": current.data,
                "token": token
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
    try {
      subs.cancel();
      print("cancelled");
    } catch (e) {
      print("Error: $e");
    }

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
            final snapShot = await collectionReference
                .doc(Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid)
                .get();
            print("snapshot:${snapShot.exists}");

            String token = await FirebaseMessaging.instance.getToken() ?? "";
            print("status is $_status");
            if (snapShot.exists && _status) {
              print("in if status is $_status");
              collectionReference
                  .doc(Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Uid)
                  .update(
                {
                  'uid': Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Uid,
                  "position": current.data
                },
              );
            } else if (_status) {
              print("else if status is $_status");
              print(
                  "Driver online ${Provider.of<AccountProvider>(context, listen: false).userAccount.CarUrl}");
              collectionReference
                  .doc(Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Uid)
                  .set(
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
                  'uid': Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Uid,
                  "position": current.data,
                  "token": token
                },
              );
            } else {
              print("else nothing");
            }
          },
        );
      } catch (e) {
        print("Error: $e");
      }
      print(
          "location lat :${_currentPosition.latitude} and long:${_currentPosition.longitude}");
    } else {
      try {
        subs.cancel();
      } catch (e) {}
      print('in else case statsus');
      try {
        geoRef.delete(Provider.of<AccountProvider>(context, listen: false)
            .userAccount
            .Uid);
        box.write('driver_status', false);
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
                        child: Provider.of<Connection>(context).isConnected
                            ? Image.network(
                                Provider.of<AccountProvider>(context,
                                        listen: false)
                                    .userAccount
                                    .Image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover)
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade900,
                                child: Center(
                                  child: Text(
                                    Provider.of<AccountProvider>(context,
                                            listen: false)
                                        .userAccount
                                        .Username
                                        .substring(0, 1),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
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
    location.enableBackgroundMode(enable: true);
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
          body: Flex(direction: Axis.vertical, children: [
            Expanded(
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
                          Provider.of<DirectionsProvider>(context).polylines ??
                              {},
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
                      isConnected =
                          Provider.of<Connection>(context).isConnected;

                      return isConnected
                          ? Container(
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
                                                child: Icon(Icons
                                                    .keyboard_arrow_up_sharp),
                                              ),
                                              Text(
                                                "Hi there,",
                                                style: GoogleFonts.openSans(
                                                    fontSize: 17.0,
                                                    fontWeight:
                                                        FontWeight.w600),
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
                                                      if (Sp.getBool(
                                                              'status') ==
                                                          null) {
                                                        _status = Sp.getBool(
                                                            "status")!;
                                                      }
                                                    } catch (e) {}
                                                    setState(() {
                                                      _status = !_status;
                                                      onlineoffline();
                                                    });
                                                  },
                                                  icon: _status
                                                      ? Icon(
                                                          Icons.gps_off_rounded)
                                                      : Icon(Icons
                                                          .gps_fixed_rounded),
                                                  label: _status
                                                      ? Text(
                                                          "Go Offline",
                                                          style: GoogleFonts
                                                              .openSans(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        )
                                                      : Text(
                                                          "Go Online",
                                                          style: GoogleFonts
                                                              .openSans(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                  style: TextButton.styleFrom(
                                                    primary: _status
                                                        ? Colors.redAccent
                                                        : Colors.green,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      side: _status
                                                          ? BorderSide(
                                                              color: Colors
                                                                  .redAccent,
                                                            )
                                                          : BorderSide(
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          "${Provider.of<AccountProvider>(context, listen: false).userAccount.Username}",
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                      Text(
                                                          "${Provider.of<AccountProvider>(context, listen: false).userAccount.Email}"
                                                                      .length >
                                                                  18
                                                              ? "${Provider.of<AccountProvider>(context, listen: false).userAccount.Email.substring(0, 15) + "..."}"
                                                              : " ${Provider.of<AccountProvider>(context, listen: false).userAccount.Email}",
                                                          style: GoogleFonts
                                                              .openSans(
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
                                                        textAlign:
                                                            TextAlign.left,
                                                        style:
                                                            GoogleFonts.dmSans(
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Image.network(
                                                      '${Provider.of<AccountProvider>(context, listen: false).userAccount.CarUrl}',
                                                      width: 140,
                                                      height: 90,
                                                      fit: BoxFit.cover),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${Provider.of<AccountProvider>(context, listen: false).userAccount.CarModel}',
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      Text(
                                                        '${Provider.of<AccountProvider>(context, listen: false).userAccount.CarNumber}',
                                                        style:
                                                            GoogleFonts.roboto(
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
                                  : !goingtopicup
                                      ? ListView(
                                          controller: scrollController,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24.0,
                                                      vertical: 18.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .arrow_drop_up_rounded,
                                                        size: 30,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                        child: Image.network(
                                                            '${user_image}',
                                                            width: 70,
                                                            height: 70,
                                                            fit: BoxFit.cover),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text("${user_name}",
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                          Text("${user_phone}",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          13,
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
                                                            " $user_rating",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: GoogleFonts
                                                                .dmSans(
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          FaIcon(Iconsax.map5),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                              "      ${user_trip_distance}" +
                                                                  " KM",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          14,
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
                                                              "     ${user_trip_time}" +
                                                                  " Min",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(' \u{20B9}',
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .black)),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                              "${user_trip_charge}" +
                                                                  " Rupees",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          14,
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
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons
                                                            .my_location_rounded),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "${user_pickup_address}",
                                                          style: GoogleFonts
                                                              .openSans(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black54),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons
                                                            .location_on_rounded),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "${user_destination_address}",
                                                          style: GoogleFonts
                                                              .openSans(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black54),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Flex(
                                                    direction: Axis.horizontal,
                                                    children: [
                                                      Expanded(
                                                        child: TextButton.icon(
                                                          style: TextButton
                                                              .styleFrom(
                                                                  primary: Colors
                                                                      .white,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black),
                                                          icon: LineIcon(
                                                              LineIcons.car),
                                                          onPressed: () {
                                                            if (payment_type ==
                                                                "Cash") {
                                                              showDialog(
                                                                  barrierDismissible:
                                                                      false,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (builder) {
                                                                    return ClassicGeneralDialogWidget(
                                                                      actions: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              vertical: 8,
                                                                              horizontal: 6),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Text(
                                                                                  "Payment (Cash)",
                                                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
                                                                                ),
                                                                                Image.asset('asset/images/cash_pay.png'),
                                                                                Text(
                                                                                  user_trip_charge + " Rupees",
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                AnimatedTextKit(
                                                                                  animatedTexts: [
                                                                                    ColorizeAnimatedText(
                                                                                      "Confirm the Payment",
                                                                                      textStyle: GoogleFonts.poppins(
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                      colors: [
                                                                                        Colors.grey.shade900,
                                                                                        Colors.grey.shade300,
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                  repeatForever: true,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 10.0),
                                                                                  child: TextButton(
                                                                                    style: TextButton.styleFrom(
                                                                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                      ),
                                                                                      backgroundColor: Colors.black,
                                                                                      primary: Colors.white,
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      DateTime now = DateTime.now();
                                                                                      var current_time = now.toLocal().toString();
                                                                                      var collectionReference = _firestore.collection('Trip_collection');
                                                                                      trip_docid = user_uid + "_" + current_time;
                                                                                      Msg().sendCashPaymentApproveByDriver(userstoken, trip_docid).then((value) {
                                                                                        collectionReference.doc(user_uid + "_" + current_time).set({
                                                                                          "userDetails": {
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
                                                                                            "user_email": user_email
                                                                                          },
                                                                                          'driverDetails': {
                                                                                            'driver_uid': Provider.of<AccountProvider>(context, listen: false).userAccount.Uid,
                                                                                            'driver_profile': Provider.of<AccountProvider>(context, listen: false).userAccount.Image,
                                                                                            'driver_email': Provider.of<AccountProvider>(context, listen: false).userAccount.Email,
                                                                                            'driver_name': Provider.of<AccountProvider>(context, listen: false).userAccount.Username,
                                                                                            'driver_phone': Provider.of<AccountProvider>(context, listen: false).userAccount.Ph,
                                                                                            'driver_rating': Provider.of<AccountProvider>(context, listen: false).userAccount.rating,
                                                                                          },
                                                                                          'cabDetails': {
                                                                                            "cab_type": Provider.of<AccountProvider>(context, listen: false).userAccount.CarClass,
                                                                                            "cab_number": Provider.of<AccountProvider>(context, listen: false).userAccount.CarNumber,
                                                                                            "cab_image": Provider.of<AccountProvider>(context, listen: false).userAccount.CarUrl,
                                                                                          },
                                                                                          'paymentDetails': {
                                                                                            "payment_type": payment_type,
                                                                                            "payment_amount": user_trip_charge,
                                                                                            "payment_time": current_time,
                                                                                          },
                                                                                          "trip_end_time": current_time,
                                                                                          'startTrip': startTrip,
                                                                                        }).then((value) async {
                                                                                          collectionReference = _firestore.collection('Trip_in_progress');
                                                                                          collectionReference.doc(user_uid).delete().then((e) {
                                                                                            subs.cancel();
                                                                                          });
                                                                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                          prefs.setBool("isinmidtrip", false);
                                                                                          prefs.setString("user_uid", "");

                                                                                          var response = prefs.setBool("isinmidtrip", false);
                                                                                          setState(() {
                                                                                            placeMarker = [];
                                                                                            Provider.of<DirectionsProvider>(context, listen: false).updateDirectionsProvider(null, null, 0, 0, {});
                                                                                            var collectionReference = _firestore.collection('Trip_in_progress');
                                                                                            var geoRef = geo.collection(collectionRef: collectionReference);
                                                                                            geoRef.delete(user_uid);
                                                                                            subs.cancel();
                                                                                            setState(() {
                                                                                              trip_details = false;
                                                                                              isinmidtrip = false;

                                                                                              prefs.setBool("status", false);
                                                                                            });
                                                                                          });
                                                                                          while (Navigator.of(context, rootNavigator: true).canPop()) {
                                                                                            Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                          }
                                                                                          showDialog(
                                                                                              barrierDismissible: false,
                                                                                              context: context,
                                                                                              builder: (builder) {
                                                                                                return ClassicGeneralDialogWidget(
                                                                                                  actions: [
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                                                                                      child: SingleChildScrollView(
                                                                                                        child: Column(
                                                                                                          children: [
                                                                                                            Text(
                                                                                                              "Trip Reviews",
                                                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
                                                                                                            ),
                                                                                                            AnimatedTextKit(
                                                                                                              animatedTexts: [
                                                                                                                ColorizeAnimatedText("Share Your Ride Experience",
                                                                                                                    textStyle: GoogleFonts.poppins(
                                                                                                                      fontSize: 15,
                                                                                                                      fontWeight: FontWeight.w600,
                                                                                                                    ),
                                                                                                                    colors: [
                                                                                                                      Colors.grey.shade900,
                                                                                                                      Colors.grey.shade300,
                                                                                                                    ]),
                                                                                                              ],
                                                                                                              repeatForever: true,
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              height: 10,
                                                                                                            ),
                                                                                                            Row(
                                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                              children: [
                                                                                                                ClipRRect(
                                                                                                                  borderRadius: BorderRadius.circular(18.0),
                                                                                                                  child: Image.network(user_image, width: 70, height: 70, fit: BoxFit.cover),
                                                                                                                ),
                                                                                                                SizedBox(
                                                                                                                  width: 30,
                                                                                                                ),
                                                                                                                Column(
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                  children: [
                                                                                                                    Text(user_name, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600)),
                                                                                                                    Row(
                                                                                                                      children: [
                                                                                                                        Icon(
                                                                                                                          LineIcons.starAlt,
                                                                                                                          color: Colors.amber,
                                                                                                                        ),
                                                                                                                        Text(
                                                                                                                          user_rating,
                                                                                                                          textAlign: TextAlign.left,
                                                                                                                          style: GoogleFonts.dmSans(
                                                                                                                            fontSize: 15,
                                                                                                                          ),
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              height: 40,
                                                                                                              child: Row(
                                                                                                                children: [
                                                                                                                  Consumer<RatingProvider>(builder: (context, value, _) {
                                                                                                                    return RatingBarIndicator(
                                                                                                                      rating: value.rating,
                                                                                                                      itemBuilder: (context, index) => Icon(
                                                                                                                        Icons.star,
                                                                                                                        color: Colors.amber,
                                                                                                                      ),
                                                                                                                      itemCount: 5,
                                                                                                                      itemSize: 30.0,
                                                                                                                      direction: Axis.horizontal,
                                                                                                                    );
                                                                                                                  }),
                                                                                                                  Container(
                                                                                                                    width: 80,
                                                                                                                    padding: EdgeInsets.only(left: 20),
                                                                                                                    child: Center(
                                                                                                                      child: TextFormField(
                                                                                                                        onChanged: (value) {
                                                                                                                          if (double.parse(value) >= 1.0 && double.parse(value) <= 5.0) {
                                                                                                                            Provider.of<RatingProvider>(context, listen: false).setRating(double.parse(value));
                                                                                                                          }
                                                                                                                        },
                                                                                                                        controller: reviewController,
                                                                                                                        keyboardType: TextInputType.number,
                                                                                                                        cursorColor: Colors.black,
                                                                                                                        decoration: InputDecoration(
                                                                                                                          contentPadding: EdgeInsets.only(top: 6, left: 12),
                                                                                                                          hintText: '4.4',
                                                                                                                          filled: true,
                                                                                                                          fillColor: Colors.grey[300],
                                                                                                                          focusColor: Colors.black,
                                                                                                                          focusedBorder: OutlineInputBorder(
                                                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                                                            borderSide: BorderSide(
                                                                                                                              color: Colors.black,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                          border: OutlineInputBorder(
                                                                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                                                                            borderSide: BorderSide(
                                                                                                                              color: Colors.grey,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              height: 20,
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              height: 35,
                                                                                                              width: 250,
                                                                                                              child: TextFormField(
                                                                                                                style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w400),
                                                                                                                controller: reviewMessageController,
                                                                                                                keyboardType: TextInputType.text,
                                                                                                                cursorColor: Colors.black,
                                                                                                                decoration: InputDecoration(
                                                                                                                  contentPadding: EdgeInsets.only(top: 6, left: 12),
                                                                                                                  hintText: "Write a review",
                                                                                                                  hintStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w400),
                                                                                                                  focusColor: Colors.black,
                                                                                                                  focusedBorder: OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                                    borderSide: BorderSide(
                                                                                                                      color: Colors.black,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  border: OutlineInputBorder(
                                                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                                                    borderSide: BorderSide(
                                                                                                                      color: Colors.grey,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              height: 10,
                                                                                                            ),
                                                                                                            Container(
                                                                                                              width: 250,
                                                                                                              child: Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                                children: [
                                                                                                                  ElevatedButton(
                                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                                                                                                        primary: Colors.black,
                                                                                                                        onPrimary: Colors.white,
                                                                                                                      ),
                                                                                                                      onPressed: () {
                                                                                                                        if (reviewMessageController.text.trim() != "") {
                                                                                                                          var collectionReference = _firestore.collection('Trip_collection');
                                                                                                                          collectionReference.doc(trip_docid).update({
                                                                                                                            "driver_review": "${reviewMessageController.text.trim()}",
                                                                                                                          });
                                                                                                                          var avg;
                                                                                                                          if (reviewController.text.trim() != "") {
                                                                                                                            _firestore.collection('Users').doc(trip_docid).get().then((value) {
                                                                                                                              double total = 0.0;
                                                                                                                              var last_5_ride_rating = value.data()!['last_5_ride_rating'];
                                                                                                                              last_5_ride_rating.removeAt(0);
                                                                                                                              last_5_ride_rating.add(reviewController.text.trim());
                                                                                                                              for (int i = 0; i < last_5_ride_rating.length; i++) {
                                                                                                                                total = total + double.parse(last_5_ride_rating[i]);
                                                                                                                              }
                                                                                                                              avg = total / 5;
                                                                                                                              if (avg.toString().length > 2) {
                                                                                                                                print("real value $avg");
                                                                                                                                avg = double.parse(avg.toString().substring(0, 3));
                                                                                                                              }
                                                                                                                              _firestore.collection('Users').doc(trip_docid).update({'rating': avg});
                                                                                                                              Msg().sendUpdateRatingValue(user_token, avg);
                                                                                                                            });
                                                                                                                          }
                                                                                                                          while (Navigator.of(context, rootNavigator: true).canPop()) {
                                                                                                                            Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                                                          }

                                                                                                                          reviewMessageController.text = "";
                                                                                                                        } else {
                                                                                                                          _scaffoldKey.currentState!.showSnackBar(
                                                                                                                            SnackBar(
                                                                                                                              content: Text("Please write a review"),
                                                                                                                              duration: Duration(seconds: 2),
                                                                                                                            ),
                                                                                                                          );
                                                                                                                        }
                                                                                                                      },
                                                                                                                      child: Text("Submit", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w400))),
                                                                                                                  ElevatedButton(
                                                                                                                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), primary: Colors.white, onPrimary: Colors.black),
                                                                                                                      onPressed: () {
                                                                                                                        while (Navigator.of(context, rootNavigator: true).canPop()) {
                                                                                                                          Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                                                        }
                                                                                                                      },
                                                                                                                      child: Text("Cancel", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w400))),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                );
                                                                                              });
                                                                                        });
                                                                                      });
                                                                                    },
                                                                                    child: Text(
                                                                                      "Payment Approve",
                                                                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            } else {
                                                              showDialog(
                                                                  barrierDismissible:
                                                                      false,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (builder) {
                                                                    return ClassicGeneralDialogWidget(
                                                                      actions: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              vertical: 8,
                                                                              horizontal: 6),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Text(
                                                                                "Payment (Online)",
                                                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
                                                                              ),
                                                                              Image.asset('asset/images/online_pay.png'),
                                                                              Text(
                                                                                user_trip_charge + " Rupee",
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              AnimatedTextKit(
                                                                                animatedTexts: [
                                                                                  ColorizeAnimatedText(
                                                                                    "Waiting for User's Payment Approval",
                                                                                    textStyle: GoogleFonts.poppins(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                    colors: [
                                                                                      Colors.grey.shade900,
                                                                                      Colors.grey.shade300,
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                                repeatForever: true,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                              Msg().sendOnlinePaymentReqFromDriver(
                                                                  user_token);
                                                            }
                                                          },
                                                          label: Text(
                                                              " End The Trip "),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView(
                                          controller: scrollController,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24.0,
                                                      vertical: 18.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .arrow_drop_up_rounded,
                                                        size: 30,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                        child: Image.network(
                                                            '${user_image}',
                                                            width: 70,
                                                            height: 70,
                                                            fit: BoxFit.cover),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text("${user_name}",
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                          Text("${user_phone}",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          13,
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
                                                            "  $user_rating",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: GoogleFonts
                                                                .dmSans(
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          FaIcon(Iconsax.map5),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                              "     ${user_trip_distance}" +
                                                                  " KM",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          14,
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
                                                              "   $user_trip_time" +
                                                                  " Min",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(' \u{20B9}',
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .black)),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                              "${user_trip_charge}" +
                                                                  " Rupees",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          14,
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
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons
                                                            .my_location_rounded),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "${user_pickup_address}",
                                                          style: GoogleFonts
                                                              .openSans(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black54),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons
                                                            .location_on_rounded),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "${user_destination_address}",
                                                          style: GoogleFonts
                                                              .openSans(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black54),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      TextButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical: 8,
                                                                )),
                                                        onPressed: () {
                                                          launch(
                                                              "tel://${user_phone}}");
                                                        },
                                                        icon: Icon(
                                                          Icons.phone,
                                                          color: Colors.white,
                                                        ),
                                                        label: Text("",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white)),
                                                      ),
                                                      TextButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical: 8,
                                                                )),
                                                        onPressed: () async {
                                                          await FirebaseAuth
                                                              .instance
                                                              .verifyPhoneNumber(
                                                            phoneNumber:
                                                                "+91${user_phone}",
                                                            verificationCompleted:
                                                                (PhoneAuthCredential
                                                                    credential) async {},
                                                            timeout:
                                                                const Duration(
                                                                    seconds:
                                                                        100),
                                                            verificationFailed:
                                                                (FirebaseAuthException
                                                                    e) async {
                                                              if (e.code ==
                                                                  'invalid-phone-number') {
                                                                Get.snackbar(
                                                                    "Phone Verfication",
                                                                    "Invalid phone number");
                                                                print(
                                                                    'The provided phone number is not valid.');
                                                              } else if (e
                                                                      .code ==
                                                                  "FirebaseTooManyRequestsException") {
                                                                Get.snackbar(
                                                                    "Phone Verfication",
                                                                    "SMS Services Error");
                                                              }
                                                              print(e);
                                                            },
                                                            codeSent:
                                                                (verificationId,
                                                                    resendingToken) async {
                                                              print(
                                                                  "Otp is send ");
                                                              Get.snackbar(
                                                                  "", "",
                                                                  titleText:
                                                                      Text(
                                                                    'OTP Verification',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                  ),
                                                                  messageText:
                                                                      Text(
                                                                    'A OTP Message is send to your Mobile number $user_phone is verify it',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ));
                                                              this.verificationId =
                                                                  verificationId;
                                                              print(
                                                                  '$verificationId here it\'s');
                                                            },
                                                            codeAutoRetrievalTimeout:
                                                                (String
                                                                    verificationId) {},
                                                          );
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            useSafeArea: true,
                                                            builder: (ctx) {
                                                              return Dialog(
                                                                child:
                                                                    Container(
                                                                  height: 450,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                  ),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      print(
                                                                          "Tap");
                                                                      FocusNode()
                                                                          .unfocus();
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(top: 20.0),
                                                                          child: Text(
                                                                              "Enter the OTP Here",
                                                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(
                                                                            vertical:
                                                                                20,
                                                                          ),
                                                                          child:
                                                                              Image.asset("asset/images/OTP_verify.png"),
                                                                        ),
                                                                        PinPut(
                                                                          fieldsCount:
                                                                              6,
                                                                          withCursor:
                                                                              true,
                                                                          smartDashesType:
                                                                              SmartDashesType.enabled,
                                                                          submittedFieldDecoration: BoxDecoration(
                                                                              color: Colors.grey.shade300,
                                                                              border: Border.all(width: 0, color: Colors.transparent),
                                                                              borderRadius: BorderRadius.circular(5.0)),
                                                                          followingFieldDecoration: BoxDecoration(
                                                                              color: Colors.grey.shade300,
                                                                              border: Border.all(width: 0, color: Colors.transparent),
                                                                              borderRadius: BorderRadius.circular(2.0)),
                                                                          selectedFieldDecoration: BoxDecoration(
                                                                              color: Colors.grey.shade400,
                                                                              border: Border.all(width: 0, color: Colors.transparent),
                                                                              borderRadius: BorderRadius.circular(5.0)),
                                                                          onSubmit:
                                                                              (pin) {
                                                                            otp =
                                                                                pin;
                                                                            print("OTP $pin");
                                                                          },
                                                                        ),
                                                                        Spacer(),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(bottom: 8.0),
                                                                          child:
                                                                              TextButton(
                                                                            style: TextButton.styleFrom(
                                                                                backgroundColor: Colors.black,
                                                                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.25),
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                )),
                                                                            onPressed:
                                                                                () async {
                                                                              PhoneAuthCredential auth = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
                                                                              try {
                                                                                FirebaseAuth.instance.signInWithCredential(auth).then((value) async {
                                                                                  while (Navigator.of(context, rootNavigator: true).canPop()) {
                                                                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                  }
                                                                                  if (value.user != null) {
                                                                                    setState(() {
                                                                                      goingtopicup = false;
                                                                                    });
                                                                                    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                                                                    placeMarker.add(Marker(markerId: MarkerId("Pick_Up"), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), infoWindow: InfoWindow(title: "Destination"), position: LatLng(double.tryParse(user_pickup_lat)!, double.tryParse(user_pickup_long)!)));
                                                                                    placeMarker.add(Marker(markerId: MarkerId("Destination"), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta), infoWindow: InfoWindow(title: "Destination"), position: LatLng(double.tryParse(user_destination_lat)!, double.tryParse(user_destination_long)!)));
                                                                                    List? the_data = await Directions(context: context, origin: "$user_pickup_lat,$user_pickup_long", destination: "$user_destination_lat,$user_destination_long", endpoint: "FindDrivingPath").getDirections();
                                                                                    newmapcontroller.animateCamera(
                                                                                      CameraUpdate.newLatLngBounds(Provider.of<DirectionsProvider>(context, listen: false).bounds!, 65.0),
                                                                                    );
                                                                                    startTrip = DateTime.now().toString();
                                                                                    Msg().sendStartTrip(user_token).then((value) {
                                                                                      sharedPreferences.setBool("reaching_destination", true);
                                                                                    });
                                                                                  }
                                                                                });
                                                                              } catch (e) {
                                                                                while (Navigator.of(context, rootNavigator: true).canPop()) {
                                                                                  Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                }

                                                                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Invalid OTP")));
                                                                              }
                                                                              print("Starting Trip $otp and ${auth}");
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              "Start Trip",
                                                                              style: TextStyle(fontSize: 15, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.sms,
                                                          color: Colors.white,
                                                        ),
                                                        label: Text("",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white)),
                                                      ),
                                                      TextButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                primary: Colors
                                                                    .black,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      20,
                                                                )),
                                                        onPressed: () async {
                                                          SharedPreferences
                                                              prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          print(
                                                              "checkisinmidtrip");

                                                          placeMarker = [];

                                                          prefs.setBool(
                                                              "isinmidtrip",
                                                              false);
                                                          prefs.setString(
                                                              "user_uid", "");
                                                          Provider.of<DirectionsProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .updateDirectionsProvider(
                                                                  null,
                                                                  null,
                                                                  0,
                                                                  0, {});

                                                          var collectionReference =
                                                              _firestore.collection(
                                                                  'Trip_in_progress');
                                                          Msg()
                                                              .sendCancelTrip(
                                                                  user_token)
                                                              .then((value) {
                                                            var geoRef =
                                                                geo.collection(
                                                                    collectionRef:
                                                                        collectionReference);
                                                            geoRef.delete(
                                                                user_uid);
                                                            subs.cancel();
                                                          });
                                                          setState(() {
                                                            trip_details =
                                                                false;
                                                            isinmidtrip = false;
                                                          });
                                                          await setDriverDetails();
                                                        },
                                                        icon: Icon(
                                                          Icons.cancel_outlined,
                                                          color: Colors.white,
                                                        ),
                                                        label: Text(
                                                            " Cancel Ride",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                            )
                          : Container(
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                controller: scrollController,
                                children: [
                                  Center(
                                    child: Text(
                                      "No Internet Connection",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 19, color: Colors.black87),
                                    ),
                                  ),
                                  Image.asset("asset/images/no_internet.png"),
                                ],
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      if (timer.isActive) {
        timer.cancel();
      }
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

  Future<void> checkisinmidtrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("checkisinmidtrip");
    var response = prefs.getBool("isinmidtrip");
    print("response :${response}");
    var docid = prefs.getString("user_uid");
    var reaching_destination = prefs.getBool("reaching_destination") ?? false;

    print("response :${docid}");
    if (response != null && response == true) {
      setState(() {
        isinmidtrip = true;
      });
      _firestore
          .collection('Trip_in_progress')
          .doc(docid)
          .get()
          .then((value) async {
        print("the trip data :${value.data()}");
        Get.snackbar("trip data",
            "${value.data()!['carDetails']['usersDetails']['user_name']}");
        if (value.data() != null) {
          print("Updating all the value");

          setState(() {
            trip_details = true;
            goingtopicup = !reaching_destination;
            userstoken =
                value.data()!['carDetails']['usersDetails']['userstoken'];
            print('userstoken here: $userstoken');
            user_pickup_lat =
                value.data()!['carDetails']['usersDetails']['user_pickup_lat'];
            user_image =
                value.data()!['carDetails']['usersDetails']['user_image'];
            user_name =
                value.data()!['carDetails']['usersDetails']['user_name'];
            user_phone =
                value.data()!['carDetails']['usersDetails']['user_phone'];
            user_pickup_long =
                value.data()!['carDetails']['usersDetails']['user_pickup_long'];
            user_destination_lat = value.data()!['carDetails']['usersDetails']
                ['user_destination_lat'];
            user_rating =
                value.data()!['carDetails']['usersDetails']['user_rating'];
            user_destination_long = value.data()!['carDetails']['usersDetails']
                ['user_destination_long'];
            user_pickup_address = value.data()!['carDetails']['usersDetails']
                ['user_pickup_address'];
            user_destination_address = value.data()!['carDetails']
                ['usersDetails']['user_destination_address'];
            user_trip_charge =
                value.data()!['carDetails']['usersDetails']['user_trip_charge'];
            user_trip_distance = value.data()!['carDetails']['usersDetails']
                ['user_trip_distance'];
            user_trip_time =
                value.data()!['carDetails']['usersDetails']['user_trip_time'];
            user_uid = value.data()!['carDetails']['usersDetails']['user_uid'];
            payment_type =
                value.data()!['carDetails']['usersDetails']['payment_type'];
            user_email =
                value.data()!['carDetails']['usersDetails']['user_email'];
            startTrip = value.data()!['startTrip'];
            pickup = LatLng(double.tryParse(user_pickup_lat)!,
                double.tryParse(user_pickup_long)!);
            destination = LatLng(double.tryParse(user_destination_lat)!,
                double.tryParse(user_destination_long)!);
            placeMarker.add(
              Marker(
                markerId: MarkerId("Pick_up"),
                infoWindow: InfoWindow(title: "Pick up place"),
                position: pickup,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
            );
            if (reaching_destination) {
              placeMarker.add(
                Marker(
                  markerId: MarkerId("Destination"),
                  infoWindow: InfoWindow(title: "Destination"),
                  position: destination,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueMagenta),
                ),
              );
            }
          });
          var collectionReference = _firestore.collection('Trip_in_progress');
          try {
            Stream<Position> DriverLocation = Geolocator.getPositionStream();
            String token = await FirebaseMessaging.instance.getToken() ?? "";
            subs = DriverLocation.listen(
              (Position position) async {
                GeoFirePoint current = geo.point(
                    latitude: position.latitude, longitude: position.longitude);
                final snapShot = await collectionReference.doc(user_uid).get();
                print("snapshot:${snapShot.exists}");

                if (snapShot.exists) {
                  collectionReference.doc(user_uid).update(
                    {
                      'uid':
                          Provider.of<AccountProvider>(context, listen: false)
                              .userAccount
                              .Uid,
                      "position": current.data
                    },
                  );
                }
              },
            );
          } catch (e) {
            print("Error: $e");
          }
          Position position = await Geolocator.getCurrentPosition();
          if (!reaching_destination) {
            directions = Directions(
                endpoint: "FindDrivingPath",
                origin: "${position.latitude},${position.longitude}",
                destination: "$user_pickup_lat,$user_pickup_long",
                context: context);
          } else {
            directions = Directions(
                endpoint: "FindDrivingPath",
                origin: "$user_pickup_lat,$user_pickup_long",
                destination: "$user_destination_lat,$user_destination_long",
                context: context);
          }
          try {
            dynamic poly = await directions.getDirections();
            print("polyline direction:${poly}");

            print("poly:$poly");
            if (poly != null) {
              setState(() {
                CameraPosition cameraPosition =
                    CameraPosition(target: pickup, zoom: 18);
                newmapcontroller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                      Provider.of<DirectionsProvider>(context, listen: false)
                          .bounds!,
                      65.0),
                );
              });
            } else {}
          } catch (e) {
            print("Error: $e");
          }
        } else {
          print("else part here ");
        }
      });
    }
  }

  @override
  void initState() {
    Provider.of<Connection>(context, listen: false).getDataConnection();
    isConnected = Provider.of<Connection>(context, listen: false).isConnected;
    getData();
    getnotification();
    checkisinmidtrip();
    setupnotification();

    super.initState();
  }
}

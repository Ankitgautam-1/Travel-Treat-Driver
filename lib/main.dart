import 'dart:async';
import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/Data/connectivityProvider.dart';
import 'package:driver/Data/files.dart';
import 'package:driver/Data/passengerProvider.dart';
import 'package:driver/Data/ratingProvider.dart';
import 'package:driver/models/Direction_provider.dart';
import 'package:driver/services/notification_service.dart';
import 'package:driver/views/Location_permission.dart';
import 'package:driver/views/ride_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:driver/Data/image.dart';
import 'package:driver/Data/userData.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/views/Dashboard.dart';
import 'package:driver/views/Maps.dart';
import 'package:driver/views/Welcome.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'Data/accountProvider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:location/location.dart' as loc;
import 'package:supabase/supabase.dart' as sm;
import 'package:get_storage/get_storage.dart';

var uid, image, username, ph, email;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await GetStorage.init();
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails("chnanelId", "channellname",
          channelDescription:
              "The Travel Treat app requires notification service to assure user and alert on required time.",
          importance: Importance.high,
          priority: Priority.high);
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationServices().init();
  final FirebaseApp app = await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final _firestore = FirebaseFirestore.instance;
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  VisualDensity.adaptivePlatformDensity;
  FirebaseMessaging.instance.getToken().then((token) => print("token:$token"));
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("title :${message.data['title']}");

    print(message.notification);
    print(message.data);
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails("chnanelId", "channellname",
            channelDescription:
                "The Travel Treat app requires notification service to assure user and alert on required time.",
            importance: Importance.high,
            priority: Priority.high);
  });
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider<ImageData>(
          create: (context) => ImageData(),
        ),
        ChangeNotifierProvider<Files>(
          create: (context) => Files(),
        ),
        ChangeNotifierProvider<DirectionsProvider>(
          create: (context) => DirectionsProvider(),
        ),
        ChangeNotifierProvider<PassengerProvider>(
          create: (context) => PassengerProvider(),
        ),
        ChangeNotifierProvider<Connection>(
          create: (context) => Connection(),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (context) => AccountProvider(),
        ),
        ChangeNotifierProvider<RatingProvider>(
          create: (context) => RatingProvider(),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'OpenSans',
        ),
        home: SafeArea(
          child: MyApp(app: app),
        ),
      ),
    ),
  );
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  final FirebaseApp app;
  MyApp({required this.app});
  @override
  _MyAppState createState() => _MyAppState(app: app);
}

class _MyAppState extends State<MyApp> {
  FirebaseApp app;
  loc.Location location = loc.Location();
  _MyAppState({required this.app});
  @override
  void initState() {
    super.initState();
    checkuid();
  }

  void _checkGps() async {
    bool locationServices = await location.serviceEnabled();
    print("val:$locationServices");
    if (!locationServices) {
      Future.delayed(
        const Duration(seconds: 4),
        () async {
          await OpenAppsSettings.openAppsSettings(
            settingsCode: SettingsCode.LOCATION,
            onCompletion: () async {
              if (await location.serviceEnabled()) {
                Get.offAll(Maps(app: app));
              } else {
                Get.offAll(LocationPermissoin(app: app));
              }
            },
          );
        },
      );
    } else {
      Timer(Duration(seconds: 5), () {
        Get.offAll(Maps(app: app));
      });
    }
  }

  void checkuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('Uid') != null) {
      uid = prefs.getString('Uid');
      username = prefs.getString('Username');
      email = prefs.getString('Email');
      image = prefs.getString('Image');
      ph = prefs.getString('Ph');
      String carClass = prefs.getString('carClass')!;
      String carModel = prefs.getString('carModel')!;
      String carNumber = prefs.getString('carNumber')!;
      String carUrl = prefs.getString('carUrl')!;
      String rating = prefs.getString('rating')!;

      Provider.of<ImageData>(context, listen: false)
          .updateimage(File(image), null);
      UserAccount userAccData = UserAccount(
          CarClass: carClass,
          CarModel: carModel,
          CarNumber: carNumber,
          CarUrl: carUrl,
          rating: rating,
          Email: email,
          Image: image ?? "",
          Ph: ph,
          Uid: uid,
          Username: username);
      Provider.of<AccountProvider>(context, listen: false)
          .updateuseraccount(userAccData);
      if (image == "") {
        try {
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('Driver_Details')
              .child('/$uid/$uid');
          String imageurl = await ref.getDownloadURL();
          print("image url is :>$imageurl");
        } catch (e) {}
      } else {
        print("Image is availabel");
      }
      _checkGps();
    } else {
      uid = "";
    }

    setState(() {
      uid = uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 5500,
      splash: 'asset/Animation/cab-animation.gif',
      backgroundColor: Colors.white,
      nextScreen: uid == "" ? Welcome(app: app) : Maps(app: app),
      splashIconSize: 350,
    );
  }
}

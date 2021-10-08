import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:driver/Data/files.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:driver/Data/image.dart';

import 'package:driver/Data/userData.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/views/Dashboard.dart';
import 'package:driver/views/Maps.dart';
import 'package:driver/views/Welcome.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Data/accountProvider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

var uid, image, username, ph, email;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  VisualDensity.adaptivePlatformDensity;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (context) => AccountProvider(),
        ),
        ChangeNotifierProvider<ImageData>(
          create: (context) => ImageData(),
        ),
        ChangeNotifierProvider<Files>(
          create: (context) => Files(),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Ubuntu',
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
  FirebaseApp app;
  MyApp({required this.app});
  @override
  _MyAppState createState() => _MyAppState(app: app);
}

class _MyAppState extends State<MyApp> {
  FirebaseApp app;
  _MyAppState({required this.app});
  @override
  void initState() {
    super.initState();
    checkuid();
  }

  void checkuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('Uid') != null) {
      uid = prefs.getString('Uid');
      username = prefs.getString('Username');
      email = prefs.getString('Email');
      image = prefs.getString('Image');
      ph = prefs.getString('Ph');
      Provider.of<ImageData>(context, listen: false).updateimage(File(image));
      UserAccount userAccData = UserAccount(
          Email: email,
          Image: image ?? "",
          Ph: ph,
          Uid: uid,
          Username: username);
      Provider.of<AccountProvider>(context, listen: false)
          .updateuseraccount(userAccData);
      // if (image == "") {
      //   try {
      //     firebase_storage.Reference ref = firebase_storage
      //         .FirebaseStorage.instance
      //         .ref()
      //         .child('Users_profile')
      //         .child('/$uid/$uid');
      //     String imageurl = await ref.getDownloadURL();
      //     print("image url is :>$imageurl");
      //   } catch (e) {}
      // } else {
      //   print("Image is availabel");
      // }
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

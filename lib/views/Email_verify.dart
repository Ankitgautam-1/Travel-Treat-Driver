import 'dart:async';
import 'dart:io';
import 'package:driver/Data/files.dart';
import 'package:driver/views/Welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driver/Data/accountProvider.dart';
import 'package:driver/Data/image.dart';
import 'package:driver/models/userAccount.dart';
import 'dart:io' as io;
import 'package:driver/views/Dashboard.dart';
import 'package:driver/views/Maps.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// ignore: must_be_immutable
class EmailVerify extends StatefulWidget {
  FirebaseApp app;

  List<dynamic> data;
  EmailVerify({required this.data, required this.app});

  @override
  _EmailVerifyState createState() => _EmailVerifyState(data: data, app: app);
}

class _EmailVerifyState extends State<EmailVerify> {
  FirebaseApp app;
  List<dynamic> data;

  _EmailVerifyState({required this.data, required this.app});

  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool isdisable = false;
  File? file1, file2, file3, file4, file5;
  @override
  void initState() {
    user = auth.currentUser;

    print(data);
    print('Checking for verification');
    timer = Timer.periodic(Duration(seconds: 4), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ImageData>(
          create: (context) => ImageData(),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 40,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {}
                timer!.cancel();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                ),
                Center(
                  child: Image.asset(
                    'asset/images/email_verification_bg.png',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Email Verification',
                  style: TextStyle(
                    fontSize: 35,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Please check your Email & Verify',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    print('inside checkEmailverified');
    user = auth.currentUser;
    print("Checking for user $user");
    await user!.reload();
    if (user!.emailVerified) {
      timer!.cancel();
      final String uid = user!.uid;

      final String username = data[0];
      final String email = data[1];
      final String ph = data[2];
      final dynamic profile = data[4];

      // UserAccount userAccData = UserAccount(
      //     Email: email, Image: profile, Ph: ph, Uid: uid, Username: username);

      try {
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('Driver_Details')
            .child('/${user!.uid}/${user!.uid}');
        print("Uploading image");
        File prof = Provider.of<ImageData>(context, listen: false).image!;
        ref.putFile(prof);

        file1 = Provider.of<Files>(context, listen: false).file1;
        file2 = Provider.of<Files>(context, listen: false).file2;
        file3 = Provider.of<Files>(context, listen: false).file3;
        file4 = Provider.of<Files>(context, listen: false).file4;
        file5 = Provider.of<Files>(context, listen: false).file5;
        ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('Driver_Details')
            .child('/${user!.uid}/${user!.uid}_file1');
        ref.putFile(file1!);

        print("first file uploaded ");
        ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('Driver_Details')
            .child('/${user!.uid}/${user!.uid}_file2');
        ref.putFile(file2!);
        print("secand file uploaded ");

        ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('Driver_Details')
            .child('/${user!.uid}/${user!.uid}_file3');
        ref.putFile(file3!);
        print("Third file uploaded ");
        ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('Driver_Details')
            .child('/${user!.uid}/${user!.uid}_file4');
        ref.putFile(file4!);
        print("Fourth file uploaded ");
        ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('Driver_Details')
            .child('/${user!.uid}/${user!.uid}_file5');
        ref.putFile(file5!);
        print("Fifth file uploaded ");
        print('Uploaded Files');
        final DatabaseReference db = FirebaseDatabase(app: app).reference();
        await db.child('Driver_response').child(uid).set(
          {
            "Username": "$username",
            "Email": "$email",
            "Phone": "$ph",
            "Image": prof.path
          },
        );
        Get.snackbar(
          "Account Creation",
          "Your response has been collected we will varify the details and give our response in with next 2 weeks for more details for more in for more info please contact us on Traveltraethelp@gmail.com ",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
        );
        await wait();
        Get.offAll(Welcome(app: app));
      } catch (e) {
        Get.snackbar("Account Creation Error", "Erorr Occured $e");
      }
    }
  }

  Future<void> wait() async {
    return Future.delayed(
      Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }
}

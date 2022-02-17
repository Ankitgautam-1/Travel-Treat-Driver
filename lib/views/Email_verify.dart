import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:supabase/supabase.dart' as sm;

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
  bool isuploading = false;
  final _firestore = FirebaseFirestore.instance;
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
                  style: GoogleFonts.openSans(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  isuploading
                      ? "Your Email is Verified"
                      : 'Please check your Email & Verify',
                  style:
                      GoogleFonts.openSans(fontSize: 17, color: Colors.black54),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: Text(
                    isuploading
                        ? "The Image is being uploaded to the server, please wait for a while don't close the app"
                        : "",
                    style: GoogleFonts.openSans(
                        fontSize: 15, color: Colors.black54),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                isuploading
                    ? Center(child: CircularProgressIndicator())
                    : Container(),
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
      setState(() {
        isuploading = true;
      });
      timer!.cancel();
      final String uid = user!.uid;

      final String username = data[0];
      final String email = data[1];
      final String ph = data[2];
      final dynamic profile = data[4];
      var collectionReference = _firestore.collection('Drivers_req');
      collectionReference.doc(uid).set({
        "Email": email.toString(),
        "Image":
            "https://ugxqtrototfqtawjhnol.supabase.in/storage/v1/object/public/travel-treat-storage/Drivers_req/${user!.uid}/${user!.uid}",
        "Phone": ph,
        "UserID": uid,
        "Username": username,
        "cabUrl":
            "https://ugxqtrototfqtawjhnol.supabase.in/storage/v1/object/public/travel-treat-storage/Drivers_req/${user!.uid}/${user!.uid}_cabimage",
        "rating": "4.3"
      });
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
        print("secand file uploaded  ${file2!.path}");

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
        File? cab = Provider.of<ImageData>(context, listen: false).cab_image;
        final client = sm.SupabaseClient(
            'https://ugxqtrototfqtawjhnol.supabase.co',
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNjM5NjQ0MzM2LCJleHAiOjE5NTUyMjAzMzZ9.7ZRfV8ekUJBSLVQWA6ylO5gdbE5BNnnD8lyZDflOgU0');
        print("client:$client");
        await client.storage
            .from('travel-treat-storage')
            .upload('Drivers_req/${user!.uid}/${user!.uid}', prof);
        await client.storage
            .from('travel-treat-storage')
            .upload('Drivers_req/${user!.uid}/${user!.uid}_cabimage', cab!);
        final storageResponse = await client.storage
            .from('travel-treat-storage')
            .upload('Drivers_req/${user!.uid}/Drivers_license', file1!);
        await client.storage
            .from('travel-treat-storage')
            .upload('Drivers_req/${user!.uid}/Drivers_NOC', file2!);
        await client.storage
            .from('travel-treat-storage')
            .upload('Drivers_req/${user!.uid}/Drivers_RC', file3!);
        await client.storage
            .from('travel-treat-storage')
            .upload('Drivers_req/${user!.uid}/Drivers_Vehicle_ins', file4!);
        await client.storage
            .from('travel-treat-storage')
            .upload('Drivers_req/${user!.uid}/Drivers_Vehicle_permit', file5!);

        print("file uploaded in supabase:${storageResponse.data}");
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

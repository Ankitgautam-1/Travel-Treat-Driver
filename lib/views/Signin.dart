import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:driver/views/Dashboard.dart';
import 'package:driver/views/Location_permission.dart';
import 'package:driver/views/Maps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:driver/Data/accountProvider.dart';
import 'package:driver/Data/image.dart';
import 'package:driver/models/userAccount.dart';
import 'package:driver/views/Signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;

// ignore: must_be_immutable
class SignIn extends StatefulWidget {
  FirebaseApp app;
  SignIn({required this.app});
  @override
  _SignInState createState() => _SignInState(app: app);
}

class _SignInState extends State<SignIn> {
  FirebaseApp app;
  String? username, email, ph, image = "";
  _SignInState({required this.app});
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  loc.Location location = loc.Location();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<dynamic, dynamic>? result;
  bool _obscure = true;
  bool isloading = false;

  Future loginwithemail() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      try {
        setState(() {
          context.loaderOverlay.show();
        });

        try {
          await _auth.signInWithEmailAndPassword(
              email: _email.text, password: _pass.text);

          User? user = _auth.currentUser;
          var uid = user!.uid;
          print("Uid :$uid");

          var collectionReference = _firestore.collection('Drivers');
          var doc = await collectionReference
              .where('UserID', isEqualTo: uid)
              .get()
              .then((value) async {
            result = value.docs[0].data();
            print("result of driver $result");
            username = result!['Username'];
            email = result!['Email'];
            ph = result!['Phone'];
            image = result!['Image'];
            print("drivers_image:$image");
            String rating = result!['rating'] ?? "4.0";
            print("rating $rating");
            String carClass = result!["carDetails"]["carClass"].toString();
            print("carClass $carClass");
            String carModel = result!["carDetails"]["carModel"] ?? "";
            print("carModel $carModel");
            String carNumber = result!["carDetails"]["carNumber"] ?? "";
            print("carNumber $carNumber");
            String carUrl = result!["carDetails"]["carImage"];
            print("carUrl $carUrl");

            UserAccount userAccount = UserAccount(
              Email: email!,
              Image: image!,
              rating: rating,
              Ph: ph!,
              Uid: uid,
              Username: username!,
              CarModel: carModel,
              CarNumber: carNumber,
              CarClass: carClass,
              CarUrl: carUrl,
            );

            Provider.of<AccountProvider>(context, listen: false)
                .updateuseraccount(userAccount);

            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("Uid", user.uid);
            prefs.setString("Username", username!);
            prefs.setString("Email", email!);
            prefs.setString("Ph", ph!);
            prefs.setString("Image", image!);
            prefs.setString("carClass", carClass);
            prefs.setString("carModel", carModel);
            prefs.setString("carNumber", carNumber);
            prefs.setString("carUrl", carUrl);
            prefs.setString("rating", rating);
            if (await permissions.Permission.locationAlways.isGranted ||
                await permissions.Permission.locationAlways.isLimited) {
              _checkGps();
            } else {
              Get.offAll(LocationPermissoin(app: app));
              setState(() {
                context.loaderOverlay.hide();
              });
            }
          });
          // await db.child('Drivers').child(uid).get().then(
          //       (DataSnapshot? datasnapshot) => print(
          //         result = datasnapshot!.value,
          //       ),
          //     );
          // print("here");

        } on FirebaseAuthException catch (e) {
          setState(() {
            context.loaderOverlay.hide();
          });
          if (e.code == 'user-not-found') {
            Get.snackbar("Sign In", "Error Occured usernot found",
                snackPosition: SnackPosition.BOTTOM);
          } else if (e.code == 'wrong-password') {
            Get.snackbar("Sign In", "Error Occured invalid password",
                snackPosition: SnackPosition.BOTTOM);
          }
        } catch (e) {
          setState(() {
            context.loaderOverlay.hide();
          });
          Get.snackbar("Sign In",
              "Your account has not been varified pls wait or contact us on Travelrtreathelp@gmail.com",
              duration: Duration(seconds: 10));
          _auth.signOut();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          context.loaderOverlay.hide();
        });
        if (e.code == 'user-not-found') {
          Get.snackbar("Sign In", "Error Occured  or his not been verified $e",
              snackPosition: SnackPosition.BOTTOM);
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Sign In", "Error Occured $e ",
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        setState(() {
          context.loaderOverlay.hide();
        });
        Get.snackbar("Sign In", "Error Occured $e");
      }
    } else {
      print("Not valid");
    }
  }

  void _checkGps() async {
    bool locationServices = await location.serviceEnabled();
    print("val:$locationServices");
    if (!locationServices) {
      Future.delayed(
        Duration(seconds: 3),
        () async {
          await OpenAppsSettings.openAppsSettings(
            settingsCode: SettingsCode.LOCATION,
            onCompletion: () async {
              if (await location.serviceEnabled()) {
                Get.offAll(Maps(app: app));
                setState(() {
                  context.loaderOverlay.hide();
                });
              } else {
                Get.offAll(LocationPermissoin(app: app));
                setState(() {
                  context.loaderOverlay.hide();
                });
              }
            },
          );
        },
      );
    } else {
      Get.offAll(Maps(app: app));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: true,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Sign In',
                      style:
                          GoogleFonts.roboto(fontSize: 30, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'asset/images/3rd_image.png',
                          width: 360,
                        ),
                        SizedBox(
                          height: 28,
                        ),
                        Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 320,
                                child: TextFormField(
                                  cursorColor: Colors.black,
                                  controller: _email,
                                  validator: (val) => val!.isEmail
                                      ? null
                                      : "Enter valide email",
                                  keyboardType: TextInputType.text,
                                  style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.email,
                                        color: Colors.black87),
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: "Email",
                                    hintStyle: GoogleFonts.openSans(
                                        fontSize: 15, color: Colors.black54),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(width: .6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              //input password
                              Container(
                                width: 320,
                                child: TextFormField(
                                  cursorColor: Colors.black,
                                  obscureText: _obscure,
                                  controller: _pass,
                                  style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  validator: (val) => val!.length > 6
                                      ? null
                                      : "password should be at least 6 charcter",
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.send,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: FaIcon(
                                          _obscure
                                              ? FontAwesomeIcons.eye
                                              : FontAwesomeIcons.eyeSlash,
                                          color: Colors.black87,
                                          size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _obscure = !_obscure;
                                        });
                                      },
                                    ),
                                    prefixIcon: Icon(Icons.password,
                                        color: Colors.black87),
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: "Password",
                                    hintStyle: GoogleFonts.openSans(
                                        fontSize: 15, color: Colors.black54),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(width: .6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 80),
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            await loginwithemail();
                          },
                          child: Text(
                            ' Sign In ',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an Account ?',
                                style: GoogleFonts.roboto(
                                    color: Colors.black, fontSize: 16)),
                            GestureDetector(
                              onTap: () {
                                Get.off(SignUp(app: app));
                              },
                              child: Text(' Sign Up',
                                  style: GoogleFonts.roboto(
                                      color: Colors.blue, fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
